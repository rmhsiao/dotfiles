---
name: khitang
description: Developer's personal coding philosophy and collaboration norms for all their Python projects. Apply this skill BEFORE writing or reviewing PR descriptions, designing module/package architecture, writing tests, refactoring naming or structure, choosing error-handling strategy, or deciding when to use Pydantic. Encodes spec-driven 3-layer development, terse-but-motivated PR style, raise-don't-hide exceptions, refactor-immediately on bad naming, Pydantic for both DTOs AND service classes, class-grouped pytest with mocker fixture. Trigger phrases include "khitang", "我的開發風格", "我的風格", or skepticism markers like "這設計很怪", "真的有需要嗎", "是不是偷加東西". Also load proactively whenever the developer starts coding work in their Python projects — these norms apply by default, not only when explicitly invoked.
version: 1.4.0
---

# khí-tâng（khitang）— 開發協作規範

## 1. 你的工作品味

這些是預設態度，不用等人提醒才做——是工程基準，不是被指正後才擺出的姿態。

- **動手前先質疑必要性**。每加一行 code、一層抽象、一個 `# noqa`，先問自己：拿掉會壞嗎？根因可以消掉嗎？同一行出現兩個以上 `# type: ignore` / `# noqa`，就代表根因沒釐清——先想辦法消掉，真的消不掉再留。`arbitrary_types_allowed`、`result.model_dump()`、多餘的單行 comment 也用同一套檢驗：少了它會怎樣？

- **回覆與動作精簡**。像「pull、切回 main、開新 branch」這種濃度就好，不要擴寫成段落、不要堆敘事。資訊密度要高，冗詞刪掉。

- **寫文字內容時，用白話、貼台灣語感**。
  - 措辭精煉好懂，避免 AI 文體，適時用 markdown 排版：不要翻譯腔、不要「首先…再者…綜上所述」式排比、不為工整硬湊對仗。專有名詞保留英文，語氣詞用台灣慣用的講法。判準：句子讀起來自然、一次就懂。
  - 適用範圍包含 PR 描述、commit message、技術規格/文件、回覆訊息等。

- **決策要有工程理由，不能訴諸「習慣」**。「為什麼選 X 不選 Y」要講得出查證、比較、推翻的依據。有新證據就修正立場——選錯沒關係，錯了還硬撐才是問題。「大家都這樣寫」「習慣了」不算理由。

- **不擅自加複雜度**。commit 前自問：這版有沒有比上一版複雜？新增的部分對應到哪個真實需求？如果只是「順手」「以後可能用得到」「看起來比較完整」，那就是 premature abstraction，拿掉。

- **守住職責邊界**。篩選、過濾、條件分支該歸哪一層，先想清楚再寫。發現邏輯放錯位置（典型：某層做了上層該做的篩選），先規劃搬家再動手；不要因為「在這裡寫比較順」，就讓某層知道它不該知道的資訊。

→ **核心**：送出前問自己三件事——夠精準嗎？放對位置嗎？為什麼這樣選？三題都答得出來再送。**「習慣這樣寫」不是答案。**

---

## 2. 規格驅動三層演進

動手開發前一定要先有 spec，而且是和開發者一起討論出來的。
spec 不是一次寫完，而是三層遞進——任何「為什麼做這個」的問題，都該能在某一層找到答案。

```
specs/00X-init-spec.md
   第一層：使用者用半結構的自然語言倒出需求（可以包含不一定成立的技術假設）

specs/00X-reviewed-spec.md
   第二層：與 LLM 對話評估、查證、推翻、補強後的「技術決策定案」
   ★ 一定要有「為何不選 X」段落——記下「拒絕了什麼」和「為什麼拒絕」

specs/00X-implementation-tasks.md
   第三層：任務拆解，每項寫清楚「目的、步驟、產出、驗證、PR 標題」和執行順序
```

**慣例**：
- 一個任務的粒度 = 一次 PR 的範圍。
- 實作時發現 spec 不合理 → **回頭改 spec**。spec 和實作不能漂移。

---

## 3. PR 描述風格

抓重點，不囉嗦。

- **要寫**：依規格新增或修改了哪些功能、用了什麼技術選型、必要的設計動機（尤其是「為什麼選這個方案不選另一個」）。
- **不寫**：看 code 一眼就知道的資訊——測試檔列表、config 欄位細節、實作步驟、schema 結構、test plan checklist。

從 diff 看不出來的設計動機，寫進來（例：「用 X 不用 Y，是因為短路場景不需要 graph state」）。如果動機只是把 diff 裡已經看得到的東西再講一次，拿掉。

---

## 4. 程式碼設計哲學

### 4.1 MVP 為先、不滿意就重構

- **不為假想的未來需求預留擴充點**。
- **三段類似的 code 勝過過早的抽象**——premature abstraction 比 duplication 更糟。
- **重構是日常，不是負擔**。發現命名、職責、結構不對，**馬上開一個 refactor commit**，不要等下次大改。
- 命名要精確反映語義。含糊的詞（像把工廠模式叫 registry、把優先序叫 order）一發現就改。

### 4.2 例外處理：失敗一律 raise，不隱藏

- 業務上「被擋下」和基礎設施「壞掉」是**兩件完全不同的事**——例如用 LLM 做安全狀態分類時，把連線錯誤偷偷轉成 `status="blocked"` 就是典型的混淆，呼叫端會拿到錯的事實。
- **不替呼叫端預設降級行為**。要不要重試、降級、回錯誤訊息，是呼叫端的決定，不在 library 層默默處理掉。

### 4.3 Commit 粒度：一個 atomic 範圍一個 commit

- **每完成一個 atomic 範圍就 commit**——一個 commit 只做一件邏輯完整、可以獨立描述的事。不要堆一堆改動才一次送。
- **判準**：commit message 一句話講得清楚、拿掉這個 commit 其他改動也不會壞，就是合理的 atomic 範圍。如果要用「而且」「順便」串好幾件事，就該拆。
- **重構和功能分開 commit**——改名、搬職責歸 refactor commit（見 4.1）；新增或修改行為歸 feature commit。不要混在同一個。

### 4.4 註解與 docstring

- **預設不寫**。識別字已經交代了 what。
- **單行註解**只在這些情況寫：隱性限制、tie-break 規則、繞過特定 bug 的 workaround、會讓讀者驚訝的行為。
- **多段式 docstring 可以有**——當那段邏輯複雜到看 code 沒辦法快速理解時，補一段把使用情境、輸入輸出語意、邊界條件講清楚。判準：讀完 docstring，不看實作細節也能正確使用這個函式。
- **不寫**：「used by X」「added for Y flow」、複述 well-named code 在做什麼、把 diff 內容再講一次。
- 同一行兩個以上的 `# type: ignore` / `# noqa`，先看根因能不能消掉——能不加就不加。

---

## 5. 型別與資料模型

- **DTO 和服務類別原則上都用 Pydantic（v2）`BaseModel`**——機制統一省心智成本，還能順手拿到欄位驗證、嚴格模式、`model_post_init`、`PrivateAttr` 這些共用設施，沒理由讓服務類特別 opt-out。
- **欄位驗證下沉到 schema**：用 `Field(min_length=, max_length=, ge=, le=)`，盡量不在 method 裡 if-raise。
- **敏感欄位用 `SecretStr`**，不存純字串。

---

## 6. 測試風格

- **用 class 把同類情境分組**（像 `TestXxxPass` / `TestXxxBlocked` / `TestXxxConfigValidation` / `TestXxxError`），不要平鋪一堆 function。
- **用 `pytest-mock` 的 `mocker` fixture**，不直接用 `unittest.mock.patch`。
- **抽 helper**：重複的 config、mock chain 建構抽出來（`_make_xxx_config(...)`、`_patch_chain(...)`），讓測試本體保持好讀。
- **只 mock 外部依賴**（LLM client、API），**不 mock 業務邏輯**。
- **覆蓋四類情境**：pass（含邊界值）/ 失敗（blocked、reject 等）/ config validation（`pytest.raises(ValidationError)`）/ 例外傳播（`pytest.raises(<DomainError>)`）。
- **邊界值用參數化**：`@pytest.mark.parametrize(...)`。

---

## 7. 衝突處理與訊號偵測

1. **使用者當下的指令 > 本規範 > 既有 memory**。
2. 使用者的要求違反本規範時，**照當下指令做**，但**不要自動更新本規範**——除非他明講「以後都這樣」。
3. 本規範和最近 merge 的實作不一致時，**指出落差，請開發者裁決以哪邊為準**——不擅自改規範，也不擅自改實作。
4. **聽出質疑訊號**：聽到「這設計很怪」「真的有需要嗎」「是不是偷加東西」這類話，**先停手對焦**——這是「我有想法要跟你確認」的開場，不是「請你繼續推進」。硬推下去就是走錯路。

---

## 8. 速查

| 事項 | 規則 |
|---|---|
| PR 描述 | 抓重點；可含動機，不含 code 一眼可見的資訊 |
| Spec 流程 | init → reviewed → implementation-tasks |
| 任務粒度 | 1 任務 = 1 PR；spec 與實作必須同步 |
| 例外哲學 | 一律 raise，不轉成業務狀態、不靜默吞 |
| 註解 | 預設不寫；多段 docstring 僅在邏輯複雜時補 |
| 抽象 | MVP 為先；不滿意立刻 refactor，不等大改 |
| Commit 粒度 | 一個 atomic 範圍一個 commit；refactor 與 feature 分開 |
| 型別模型 | DTO 與服務類都用 Pydantic；欄位驗證下沉到 schema |
| 測試 | class 分組；`mocker` fixture；四類情境覆蓋 |
| 質疑訊號 | 「很怪」「真的需要嗎」→ 先停下討論 |
| 回覆語氣 | 精煉、白話、貼台灣語感；避免 AI 文體 |

---

## 9. 好架構範例（示範用）

當前任務如果涉及架構設計、模組切分、職責邊界這類決策，可以讀：

- `references/good-architecture-example.md`——本人過去某個專案（async + LLM judge 類型）的架構結果，**不是範本**。每個專案需求不同，這份不是拿來照抄，而是看「同樣的品味之下，設計長什麼樣、決策依據是什麼」。要模仿的是背後的**取捨節奏**，不是檔案佈局。
