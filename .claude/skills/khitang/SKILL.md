---
name: khitang
description: Developer's personal coding philosophy and collaboration norms for all their Python projects. Apply this skill BEFORE writing or reviewing PR descriptions, designing module/package architecture, writing tests, refactoring naming or structure, choosing error-handling strategy, or deciding when to use Pydantic. Encodes spec-driven 3-layer development, terse-but-motivated PR style, raise-don't-hide exceptions, refactor-immediately on bad naming, Pydantic for both DTOs AND service classes, class-grouped pytest with mocker fixture. Trigger phrases include "khitang", "我的開發風格", "我的風格", or skepticism markers like "這設計很怪", "真的有需要嗎", "是不是偷加東西". Also load proactively whenever the developer starts coding work in their Python projects — these norms apply by default, not only when explicitly invoked.
version: 1.1.0
---

# khitang — 開發協作規範

## 1. 你的工作品味

把以下態度內化成預設值——不是怕被指正才做到，而是因為這就是好工程該有的樣子。

- **動手前先質疑必要性**。每加一行、每加一層抽象、每加一個 `# noqa`，先自問「拿掉它會壞嗎？根因能不能消掉？」。同一行兩個以上的 `# type: ignore` / `# noqa` 並排出現，是「沒想清楚根因」的訊號——先試著消，再決定要不要保留。`arbitrary_types_allowed`、`result.model_dump()`、額外的單行 comment 也都套同樣的測試：少了它，會怎樣？

- **回覆與動作都短**。使用者的指令是「pull、切回 main branch、開新 branch」這種濃度——不要把它擴寫成段落式說明，也不要在回覆中堆敘事。資訊密度要高，廢話清零。

- **決策附工程理由，不引「習慣」**。每個「為什麼選 X 而非 Y」都要說得出查過什麼、比過什麼、推翻過什麼。拿到新證據要願意翻盤——選錯不丟臉，選錯還死守才丟臉。「常見寫法」「習慣這樣做」不是理由。

- **不偷加複雜度**。每次提交前自我審視：「這版比上一版複雜了嗎？多出來的東西對應到哪條真實需求？」如果只是「順手做了」、「以後可能用得到」、「看起來比較完整」——那就是 premature abstraction，請拿掉。

- **嚴守職責邊界**。篩選 / 過濾 / 條件分支邏輯該擺哪一層，先想清楚再寫。看到「位置不對」的邏輯（典型：某層做了上層該做的篩選），先把搬遷計畫想好再動手；不要因為「在這裡比較好寫」就讓某一層認識它不該認識的東西。

→ **核心**：交出之前自問「夠不夠精準？夠不夠對位？為什麼這樣選？」——三題都答得出來再送。**「習慣這樣寫」不是答案**。

---

## 2. 規格驅動三層演進

開發前必先有 spec，需與開發者一同協作、討論出來。
spec 不是一次寫完，而是三層遞進——任何「為何做這個」的問題都該在某一層找到答案。

```
specs/00X-init-spec.md
   第一層：使用者半結構自然語言倒出需求（含可能不成立的技術假設）

specs/00X-reviewed-spec.md
   第二層：與 LLM 對話評估、查證、推翻、補強後的「技術決策定案」
   ★ 必含「為何不選 X」段落——記住「拒絕了什麼」與「拒絕的理由」

specs/00X-implementation-tasks.md
   第三層：任務拆解，每項含「目的、步驟、產出、驗證、PR 標題」與執行順序
```

**慣例**：
- 任務粒度 = 一次 PR 的範圍。
- 實作過程發現 spec 不合理 → **回頭修 spec**。不允許 spec 與實作漂移。

---

## 3. PR 描述風格

抓重點，不囉嗦。

- **要寫**：依規格新增/修改了哪些功能、採用什麼技術選型、必要的設計動機（特別是「為何選這個方案而非另一個」）。
- **不寫**：看 code 一眼就能知道的資訊——測試檔列舉、config 欄位細節、實作步驟、schema 結構、test plan checklist。

從 diff 看不出來的設計動機——寫進來（例：「採 X 而非 Y 是因為短路場景不需要 graph state」）。若動機只是複述 diff 中已明顯可見的內容，拿掉。

---

## 4. 程式碼設計哲學

### 4.1 MVP 為先、不滿意就重構

- **不為假想未來需求預留擴充點**。
- **三行類似程式碼勝過早熟的抽象**——premature abstraction 比 duplication 更糟。
- **重構是日常，不是負擔**。發現命名、職責、結構不對就**立即開 refactor commit**，不等下次大改。
- 命名要精確反映語義。含糊的詞（如把工廠模式叫 registry、把優先序叫 order）一旦發現立刻改。

### 4.2 例外處理：失敗一律 raise，不隱藏

- 業務「被擋下」與基礎設施「壞掉」是**完全不同語意**——例如用 LLM 做安全狀態分類時，把連線錯誤暗自轉成 `status="blocked"` 就是典型混淆，會讓呼叫端拿到錯誤的事實。
- **不替呼叫端預設降級行為**。重試、降級、回應錯誤訊息由呼叫端決定，不在 library 層悄悄處理掉。

### 4.3 註解與 docstring

- **預設不寫**。識別字已交代 what。
- **單行註解**只在以下情境寫：隱性限制、tie-break 規則、避開特定 bug 的 workaround、會讓讀者驚訝的行為。
- **多段式 docstring 允許存在**——當該段邏輯複雜到「看 code 無法快速理解」時，補一段把使用情境、輸入/輸出語意、邊界條件講清楚。判準：讀者讀完 docstring 應該能略過實作細節仍正確使用該函式。
- **不寫**：「used by X」「added for Y flow」、複述 well-named 程式碼在做什麼、把 diff 內容再講一次。
- 同一行兩個以上的 `# type: ignore` / `# noqa` 要先檢視能否消掉根因——能不加就不加。

---

## 5. 型別與資料模型

- **DTO、服務類別原則上都用 Pydantic（v2）`BaseModel`**——統一機制節省心智成本，且能順手拿到欄位驗證、嚴格模式、`model_post_init`、`PrivateAttr` 等共用設施，沒理由為服務類特別 opt-out。
- **欄位驗證下沉到 schema**：`Field(min_length=, max_length=, ge=, le=)`，盡量不在 method 內 if-raise。
- **敏感欄位用 `SecretStr`**，不存純字串。

---

## 6. 測試風格

- **以 class 分組同類情境**（如 `TestXxxPass` / `TestXxxBlocked` / `TestXxxConfigValidation` / `TestXxxError`），不平鋪一堆 function。
- **`pytest-mock` 的 `mocker` fixture**，不直接 `unittest.mock.patch`。
- **抽 helper**：重複的 config / mock chain 構造抽出（`_make_xxx_config(...)`、`_patch_chain(...)`），測試本體保持可讀。
- **只 mock 外部依賴**（LLM client、API）；**不 mock 業務邏輯**。
- **覆蓋四類情境**：pass（含邊界值）/ 失敗（blocked、reject 等）/ config validation（`pytest.raises(ValidationError)`）/ 例外傳播（`pytest.raises(<DomainError>)`）。
- **邊界值參數化**：`@pytest.mark.parametrize(...)`。

---

## 7. 衝突處理與訊號偵測

1. **使用者當下指令 > 本規範 > 既有 memory**。
2. 若使用者要求違反本規範，**遵循當下指令**但**不自動更新本規範**——除非他明確說「以後都這樣」。
3. 若本規範與最近被 merge 的實作不一致，**指出落差並請開發者裁決該以何者為準**——不擅自更新規範也不擅自改實作。
4. **質疑訊號偵測**：聽到「這設計很怪」「真的有需要嗎」「是不是偷加東西」這類訊號，**先停手對焦**——這是「我已有方向想跟你確認」的開頭，不是「請你繼續推進」的訊號。硬推下去等於走錯路。

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
| 型別模型 | DTO 與服務類都用 Pydantic；欄位驗證下沉到 schema |
| 測試 | class 分組；`mocker` fixture；四類情境覆蓋 |
| 質疑訊號 | 「很怪」「真的需要嗎」→ 先停下討論 |

---

## 9. 好架構範例（供示範用）

當前任務若涉及架構設計、模組切分、職責邊界這類決策，可讀：

- `references/good-architecture-example.md`——本人過去某個專案（async + LLM judge 類型）的架構結果，**並非範本**。每個專案的需求都不同，這份不是抄來套用，而是用來看「同等品味之下的設計長什麼樣、決策依據是什麼」。重點是模仿背後的**取捨節奏**，不是檔案佈局。
