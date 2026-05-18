---
name: tpi-104-job-search
description: Searches the 104 人力銀行 (104.com.tw) job board via its public JSON APIs and returns results tailored for a Taiwan-based AI/LLM engineer evaluating career moves. Use this skill whenever the user asks to find, search, browse, or evaluate jobs on 104 — including phrases like "幫我找 104 上的...職缺", "search 104 for AI engineer jobs", "有什麼新的 LLM 職缺", "看看 104 有沒有...在徵人", or any time the user wants to filter Taiwan job listings by keyword, location, job category, or experience level. Also triggers when the user gives a 104 job URL or job ID and wants it summarized or evaluated. Do NOT use for LinkedIn, CakeResume, Yourator, or other boards.
---

# 104 Job Search (for AI/LLM engineers)

## What this skill does

Queries the 104 人力銀行 JSON APIs, filters the raw results down to what actually matters for evaluating a job, and returns a Markdown report with:

1. A **shortlist table** — title, company, location, posting date, 104 link, fit score
2. A **per-job breakdown** of the top matches — key skills table + fit reasoning
3. **Recommendations** ranked by fit with the user's AI/LLM background

This skill does NOT submit applications, save jobs to a DB, or run on a schedule. It is for ad-hoc "find me something interesting right now" queries during a conversation.

## When the user asks, follow this workflow

### Step 1 — Clarify the query (only if needed)

If the user's request is specific enough (e.g. "find LLM engineer jobs in Taipei posted in the last week"), skip to Step 2. Only ask for clarification if a critical filter is ambiguous — usually one of:

- **Keyword**: what to search for (`LLM`, `RAG`, `MLOps`, etc.)
- **Location**: defaults to Taipei + New Taipei (`6001001000,6001002000`) unless the user says otherwise
- **Recency**: if they say "recent" / "new" / "最近", use `isnew=7` (past week)

Do not interrogate — one short clarifying question at most. When in doubt, pick a sensible default, state the assumption, and proceed.

### Step 2 — Build the search request

Use the **Search API** (see `references/api.md` for the full spec):

```
GET https://www.104.com.tw/jobs/search/api/jobs
```

Required request shape:

- `User-Agent` header set to a normal browser string
- `Referer: https://www.104.com.tw/jobs/search/`
- Params: `keyword`, `area`, `jobcat` (if the user named a category), `pagesize=30`, plus recency/experience filters as appropriate

**Resolving `area` and `jobcat` codes — delegate to a subagent**

Do **not** read `Area.json` or `JobCat.json` yourself in the main conversation. JobCat.json in particular is large and will bloat the main context with hundreds of tree nodes that won't be referenced again. Instead, use the Task tool to spawn a general-purpose subagent **on the Sonnet model** for this lookup.

Invoke the subagent with a prompt like:

> Use a subagent (model: sonnet) to resolve 104 codes. Read `references/Area.json` (for area) or `references/JobCat.json` (for jobcat). For each of the following user descriptions, walk the JSON tree and return the matching codes.
>
> **Inputs**
> - Lookup type: `area` | `jobcat`
> - User description: `<e.g. "雙北" or "LLM 工程師">`
> - Reference file: `references/Area.json` | `references/JobCat.json`
>
> **What to do**
> 1. Read the JSON with the Read tool. Inspect the actual field names (likely `no`/`des`/`n`, possibly `code`/`description`/`children`). Don't assume; inspect.
> 2. Walk the tree; match user keywords as substrings against the display-name field. Case-insensitive for English.
> 3. **Area**: prefer city/county level (e.g. 台北市 = `6001001000`), not district level, unless the user named a district. Handle common groupings: 雙北 → 台北市 + 新北市; 北北桃 → 加桃園市; 竹科 → 新竹市 + 新竹縣.
> 4. **JobCat**: prefer the most specific (leaf) nodes. 104's Search API usually only accepts leaf codes, not parent codes. For broad terms like "AI 相關" / "LLM", return the **superset** — AI 工程師 + 機器學習 + 演算法 + 資料科學家 + 軟體工程師 — wider is better than missing relevant jobs.
> 5. Return **exactly** in this format, nothing else:
>
> ```
> type: <area|jobcat>
> codes: <comma-separated codes, no spaces>
> resolved:
>   - <code>  <full-path-name>
>   - <code>  <full-path-name>
> notes: <one line — choice rationale or "no match">
> ```
>
> **Constraints**
> - Do not call any web APIs. Purely local JSON lookup.
> - Do not invent codes. Empty result → empty `codes:` field, explain in `notes:`.
> - Do not read files outside `references/`.

If both `area` and `jobcat` need resolving, spawn the two subagent calls **in parallel** (both in the same turn) — they're independent lookups.

Parse the subagent's `codes:` line and use it directly as the `area` or `jobcat` param value.

**When to skip jobcat entirely**

For AI/LLM searches where the user didn't name a category explicitly, prefer **keyword-only** search (`keyword=LLM` or `keyword=AI工程師`) and don't call the jobcat subagent. Adding `jobcat` too narrowly filters out relevant postings categorised as "軟體工程師" rather than "AI工程師".

Other filter codes (`isnew`, `jobexp`, `edu`, `remoteWork`, `order`, `zone`) are small and fixed — read them directly from `references/codes.md`, no subagent needed.

### Step 3 — Fetch and slim down

From the Search API response, extract ONLY these fields per job (everything else is noise for this use case):

- `jobName`, `custName`, `jobAddrNoDesc`, `appearDate`
- `link.job` (full URL) and derived `jobId` (last path segment)
- `description` (first ~200 chars, for preview only)
- `coIndustryDesc` (industry — useful for context)

Drop internal tracking fields like `hrBehaviorPR`, `interactionRecord`, `major`, etc.

### Step 4 — Decide which jobs deserve Content API calls

The Content API (`/job/ajax/content/{jobId}`) is expensive — one call per job, with rate limits shared across both APIs. Default rule:

- Fetch Content API details **only for the top ~5 candidates** after an initial ranking by keyword match + recency
- If the user explicitly asks for "all" or "every" job's details, push back: "We have N results; fetching full details for all of them means N extra requests. Want me to do top 10 instead?"
- Skip Content API entirely if the user just wants a quick scan of titles

When calling the Content API, extract only:

- `condition.workExp`, `condition.edu`
- `condition.specialty[].description` (this is the structured skill list — the most valuable field)
- `jobDetail.jobDescription` (full JD text)
- `jobDetail.salary`, `salaryMin`, `salaryMax`
- `jobDetail.addressRegion`, `remoteWork`
- `jobDetail.jobCategory[]` (title classification)

### Step 5 — Compute fit and produce the report

Score each job using the rubric in `references/fit_rubric.md`. The rubric is tuned to the user's profile: AI/LLM engineer, ~5 years experience, strong in RAG / guardrails / vLLM deployment, finance-domain background, exploring moves.

Then produce the output format below. **Always produce the report as Markdown, and never dump raw JSON to the user** — the whole point of the skill is to save the user from reading JSON.

## Output format

Use this structure exactly. Writing as a report, in 繁體中文 unless the user wrote to you in English.

```markdown
# 104 職缺搜尋結果

**查詢條件**: <keyword>, <location>, <recency>, <其他 filter>
**命中**: <total> 筆 / 顯示前 <shown> 筆
**搜尋時間**: <YYYY-MM-DD HH:MM>

## 職缺一覽

| # | 職稱 | 公司 | 地點 | 刊登 | 契合度 | 連結 |
|---|------|------|------|------|--------|------|
| 1 | ... | ... | ... | ... | ⭐⭐⭐⭐⭐ | [104](url) |

## Top 推薦

### 1. <職稱> – <公司>  ⭐⭐⭐⭐⭐

**為什麼推薦**: <一兩句話，對準使用者的背景具體指出契合點。不要空泛講「符合你的技能」。>

**關鍵技能**

| 類別 | 內容 |
|------|------|
| 必備 | ... |
| 加分 | ... |
| 經驗 | <workExp> |
| 學歷 | <edu> |

**工作內容摘要**: <JD 濃縮成 3–5 條要點>

**薪資 / 地點**: <salary> · <addressRegion> · <remoteWork 若非 null>

**需要留意的點**: <例如：offer 寫待遇面議、要求外派、產業不熟等。若無則略>

🔗 <104 連結>

---

(重複 2, 3, 4...)

## 其他值得一看

(若有，簡短 bullet list，title – company – 一句理由)

## 沒選進推薦的原因

(若契合度低的項目多，提一行彙總，例如「5 筆偏向偏資淺、3 筆要求 Azure-only，1 筆是外派」)
```

## Fit score presentation

Use ⭐ 1–5:

- ⭐⭐⭐⭐⭐ – 技能 + 年資 + 領域都很貼，強烈建議看
- ⭐⭐⭐⭐ – 技能 core match，年資/領域其中一項有差距
- ⭐⭐⭐ – 能做，但不是最契合
- ⭐⭐ – 邊緣，大概只 1–2 個點對上
- ⭐ – 關鍵字匹配但實際不是目標職位（例如 "AI" 出現在產品描述而非職位本身）

Only include ⭐⭐⭐ and above in "Top 推薦". ⭐⭐ 以下 goes into "其他值得一看" or "沒選進推薦的原因".

## References

Read the relevant file when you need the detail:

- `references/api.md` — API endpoints, request headers, response schemas, sample code, error handling
- `references/codes.md` — non-JSON filter codes (`isnew`, `jobexp`, `edu`, `remoteWork`, `order`, `zone`)
- `references/fit_rubric.md` — how to score jobs against the user's profile

Files read by the code-resolver subagent (do **not** read these from the main conversation):

- `references/Area.json` — full area code tree
- `references/JobCat.json` — full job category code tree

## Constraints and tone

- 回覆用繁體中文（除非使用者用英文問）
- 不要用「哈哈」或類似語助詞
- 直接給結論，不要 "根據你的需求我將..." 這類 filler
- 薪資面議就直接寫「面議」，不要猜
- 沒查到的欄位寫「—」，不要編造
- 如果 API 回傳 HTTP 429 或 403，停止、告訴使用者被限流、建議過幾分鐘再試，不要硬上
