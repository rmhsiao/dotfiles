# 契合度評分準則

職缺對應到使用者（資深 AI/LLM 工程師，~5 年經驗，正在評估換工作）的契合度。

## 使用者核心檔案

- **角色**: 資深演算法 / R&D 工程師，LLM 產品化方向
- **年資**: ~5 年，屬於 mid-senior
- **專長三層**:
  1. **強項**: RAG 系統、Guardrails（NeMo Guardrails、PII 偵測、prompt injection 防禦）、vLLM 部署、結構化輸出（xgrammar / outlines）、Embedding/Reranker 模型部署
  2. **熟悉**: Python、Docker、LangChain/LangGraph、FastAPI、NER/PII（Presidio、GLiNER）、OWASP LLM Top 10、Celery
  3. **領域經驗**: 金融（證券業），中文處理、客服/通話語音場景
- **興趣方向（換工作時會加分）**: AI Agent infra、Model deployment、LLM evaluation、安全/對齊
- **避開**: 純前端、純 DevOps、偏 data engineering（非 ML）、純管理職、只會用 OpenAI API 沒底層的 wrapper 角色

## 評分維度

每個維度 0–2 分，總分 0–10，再換成 ⭐ 1–5。

### 1. Role type match (0–2)

- `2`: 明確寫 LLM / Generative AI / ML Engineer / AI Engineer / Algorithm Engineer
- `1`: Software Engineer 但 JD 裡提到 ML/AI 是核心職責
- `0`: 掛 "AI" 但實際是產品/業務/BD / 資料分析師 / pure backend

### 2. Skill overlap (0–2)

看 `condition.specialty[]` + `jobDetail.jobDescription` 裡命中的關鍵字:

- `2`: 3 個以上強項命中（例如同時提到 RAG + vLLM + guardrails 任一組合）
- `1`: 1–2 個強項命中，或多個熟悉層命中
- `0`: 只有 Python 這種泛用技能命中

**強項命中關鍵字**: RAG、retrieval augmented、vector、embedding、reranker、guardrails、prompt injection、vLLM、serving、inference、deploy LLM、structured output、NeMo、LangGraph、agent framework、fine-tun、LoRA、evaluation、red team

### 3. Seniority fit (0–2)

依 `condition.workExp`:

- `2`: 3–7 年 / "3 年以上" / "5 年以上"
- `1`: "不拘" (通常意味偏中階) 或 "1–3 年"（可能略資淺）
- `0`: "10 年以上"（太資深）、"1 年以下"（明顯 junior）

### 4. Domain / company fit (0–2)

- `2`: 金融業（銀行/證券/保險/Fintech）+ AI 職缺 — 能帶過往經驗
- `2`: 有名的 AI 產品公司 / 有自研 LLM 應用 / 紮實的工程團隊
- `1`: 一般軟體業、數位內容、電商
- `0`: SI / 顧問業外包性質、看起來是 buzzword 驅動、或產業資訊明顯不符

### 5. Red flags (0–2, 從 2 扣)

看到以下扣分：

- 要求外派（中國/東南亞）: -1
- 薪資區間明顯偏低（月薪 < 80k 且寫數字，非面議）: -1
- JD 寫得很空泛、像拼湊關鍵字: -1
- 僅要求「會用 OpenAI API」，沒有任何深度: -1
- 要求 9–10 小時輪班、「可配合加班」用粗體: -1

起始 2 分，每個 red flag 扣 1，最低 0。

## 分數 → ⭐ 對應

| 總分 | ⭐ | 意義 |
|------|----|------|
| 9–10 | ⭐⭐⭐⭐⭐ | 三層都貼（skill + seniority + domain），強烈建議看 |
| 7–8 | ⭐⭐⭐⭐ | core match，1 個面向略有差距 |
| 5–6 | ⭐⭐⭐ | 能做但不是最契合，如果薪資好可以看 |
| 3–4 | ⭐⭐ | 邊緣，多半放到「其他值得一看」 |
| 0–2 | ⭐ | 關鍵字命中但不是目標職位 |

## 推薦理由寫法

寫「為什麼推薦」時要**具體**。不要說「符合你的技能」，要說：

- ✅ 「JD 明確提到 vLLM + guided decoding，跟你最近在做的結構化輸出直接對應」
- ✅ 「是證券業的 AI team，你之前在群益的 RAG 經驗可直接複用」
- ❌ 「技術棧符合你的背景」← 空話
- ❌ 「這是一個很好的 AI 工程師職位」← 廢話

如果沒有具體的對接點，就不要硬推。寧願少推一個也不要水。
