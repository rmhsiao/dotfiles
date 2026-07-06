---
name: khitang
description: Developer's personal coding philosophy and collaboration norms for all their Python projects. Apply this skill BEFORE writing or reviewing PR descriptions, designing module/package architecture, writing tests, refactoring naming or structure, choosing error-handling strategy, or deciding when to use Pydantic. Encodes spec-driven 3-layer development, terse-but-motivated PR style, raise-don't-hide exceptions, refactor-immediately on bad naming, Pydantic for both DTOs AND service classes, class-grouped pytest with mocker fixture. Trigger phrases include "khitang", "我的開發風格", "我的風格", or skepticism markers like "這設計很怪", "真的有需要嗎", "是不是偷加東西". Also load proactively whenever the developer starts coding work in their Python projects — these norms apply by default, not only when explicitly invoked.
version: 1.4.2
---

# khí-tâng（khitang）— 開發協作規範

## 1. 你的工作品味

以下為預設態度，不需提醒即執行——這是工程基準，不是被指正後的姿態。

- **動手前先質疑必要性**。每新增一行 code、一層抽象、一個 `# noqa`，先確認：拿掉會壞嗎？根因能否消除？
  - 同一行出現兩個以上 `# type: ignore` / `# noqa`，代表根因未釐清——先消除，確定無法消除再保留。
  - `arbitrary_types_allowed`、`result.model_dump()`、多餘的單行 comment 適用同一檢驗：少了它會怎樣？

- **回覆與動作精簡**。維持「pull、切回 main、開新 branch」這種指令濃度，不擴寫成段落、不堆疊敘事。資訊密度要高，刪去冗詞。

- **文字內容用白話、貼台灣語感**。措辭精煉易懂，避免 AI 文體，適時用 markdown 排版。
  - 不用翻譯腔、不用「首先…再者…綜上所述」式排比、不為工整刻意對仗。
  - 專有名詞保留英文；語氣詞用台灣慣用語。
  - 避免過長句子，可利用 markdown 格式拆分為清單。
  - 判準：語句自然、一次可解。
  - 適用範圍：PR 描述、commit message、技術規格/文件、回覆訊息等。

- **決策附工程理由，不訴諸「習慣」**。
  - 「為什麼選 X 不選 Y」要有查證、比較、推翻的依據；「大家都這樣寫」「習慣了」不算理由。
  - 出現新證據就修正立場——選錯不是問題，堅持錯誤才是。

- **不擅自增加複雜度**。commit 前自檢：
  - 這版是否比前一版複雜？
  - 新增部分對應哪個真實需求？
  - 若只是「順手」「未來可能用到」「看起來較完整」，即屬 premature abstraction，移除。

- **守住職責邊界**。篩選、過濾、條件分支歸哪一層，先釐清再實作。
  - 發現邏輯放錯位置（典型：某層做了上層該做的篩選），先規劃搬移再修改。
  - 不因「在這裡寫比較順」讓某層接觸不該知道的資訊。

→ **核心**：送出前確認三件事——夠精準嗎？放對位置嗎？為什麼這樣選？三題都能回答才送出。**「習慣這樣寫」不是答案。**

---

## 2. 規格驅動三層演進

動手開發前必須先有 spec，且需與開發者共同討論產出。
spec 不是一次寫完，而是三層遞進——任何「為什麼做這個」的問題，都應能在某一層找到答案。

```
specs/00X-init-spec.md
   第一層：使用者用半結構自然語言倒出需求（可包含不一定成立的技術假設）

specs/00X-reviewed-spec.md
   第二層：與 LLM 對話評估、查證、推翻、補強後的「技術決策定案」
   ★ 必含「為何不選 X」段落——記下「拒絕了什麼」與「拒絕的理由」

specs/00X-implementation-tasks.md
   第三層：任務拆解，每項寫明「目的、步驟、產出、驗證、PR 標題」與執行順序
```

**慣例**：
- 任務粒度 = 一次 PR 的範圍。
- 實作中發現 spec 不合理 → **回頭修 spec**。spec 與實作不得漂移。

---

## 3. PR 描述風格

抓重點，不囉嗦。

- **要寫**：
  - 依規格新增或修改了哪些功能、採用的技術選型。
  - 從 diff 看不出來的設計動機，尤其是「為何選這個方案而非另一個」（例：「採 X 而非 Y，因為短路場景不需要 graph state」）。
- **不寫**：
  - 看 code 一眼即知的資訊——測試檔列表、config 欄位細節、實作步驟、schema 結構、test plan checklist。
  - 只是複述 diff 已可見內容的動機。

---

## 4. 程式碼設計哲學

### 4.1 MVP 為先、不滿意就重構

- **不為假想的未來需求預留擴充點**。
- **三段類似的 code 勝過過早的抽象**——premature abstraction 比 duplication 更糟。
- **重構是日常，不是負擔**。發現命名、職責、結構不對，**立即開 refactor commit**，不等下次大改。
- 命名要精確反映語義。含糊的詞（如把工廠模式叫 registry、把優先序叫 order）一經發現立即改。

### 4.2 例外處理：失敗一律 raise，不隱藏

- 業務「被擋下」與基礎設施「壞掉」是**兩種完全不同的語意**。
  - 典型混淆：用 LLM 做安全狀態分類時，把連線錯誤轉成 `status="blocked"`——呼叫端會拿到錯誤的事實。
- **不替呼叫端預設降級行為**。重試、降級、回應錯誤訊息由呼叫端決定，不在 library 層私下處理。

### 4.3 Commit 粒度：一個 atomic 範圍一個 commit

- **每完成一個 atomic 範圍就 commit**——一個 commit 只做一件邏輯完整、可獨立描述的事。不累積多項改動一次送出。
- **判準**：
  - commit message 一句話講得清楚、拿掉這個 commit 其餘改動不會壞 → 合理的 atomic 範圍。
  - 需要用「而且」「順便」串起多件事 → 該拆。
- **重構與功能分開 commit**——改名、搬移職責歸 refactor commit（見 4.1）；新增或修改行為歸 feature commit。不混在同一個。

### 4.4 註解與 docstring

- **預設不寫**。識別字已交代 what。
- **單行註解**僅在以下情況寫：隱性限制、tie-break 規則、繞過特定 bug 的 workaround、會讓讀者驚訝的行為。
- **多段式 docstring 可以存在**——僅在邏輯複雜到看 code 無法快速理解時，說明使用情境、輸入輸出語意、邊界條件。
  - 判準：讀完 docstring，不看實作細節也能正確使用該函式。
- **不寫**：「used by X」「added for Y flow」、複述 well-named code 在做什麼、把 diff 內容再講一次。
- 同一行兩個以上的 `# type: ignore` / `# noqa`，先檢視根因能否消除——能不加就不加。

---

## 5. 型別與資料模型

- **DTO 與服務類別原則上都用 Pydantic（v2）`BaseModel`**。
  - 機制統一可省心智成本，並直接取得欄位驗證、嚴格模式、`model_post_init`、`PrivateAttr` 等共用設施。
  - 沒有理由讓服務類特別 opt-out。
- **欄位驗證下沉到 schema**：用 `Field(min_length=, max_length=, ge=, le=)`，盡量不在 method 內 if-raise。
- **敏感欄位用 `SecretStr`**，不存純字串。

---

## 6. 測試風格

- **用 class 分組同類情境**（如 `TestXxxPass` / `TestXxxBlocked` / `TestXxxConfigValidation` / `TestXxxError`），不平鋪一堆 function。
- **用 `pytest-mock` 的 `mocker` fixture**，不直接用 `unittest.mock.patch`。
- **抽 helper**：重複的 config、mock chain 建構抽出（`_make_xxx_config(...)`、`_patch_chain(...)`），維持測試本體可讀。
- **只 mock 外部依賴**（LLM client、API），**不 mock 業務邏輯**。
- **覆蓋四類情境**：
  - pass（含邊界值）
  - 失敗（blocked、reject 等）
  - config validation（`pytest.raises(ValidationError)`）
  - 例外傳播（`pytest.raises(<DomainError>)`）
- **邊界值用參數化**：`@pytest.mark.parametrize(...)`。

---

## 7. 衝突處理與訊號偵測

1. **使用者當下指令 > 本規範 > 既有 memory**。
2. 使用者的要求違反本規範時，**照當下指令執行**，但**不自動更新本規範**——除非明確說「以後都這樣」。
3. 本規範與最近 merge 的實作不一致時，**指出落差，由開發者裁決以何者為準**——不擅自改規範，也不擅自改實作。
4. **質疑訊號偵測**：聽到「這設計很怪」「真的有需要嗎」「是不是偷加東西」這類訊號，**先停手對焦**。
   - 這是「我有方向要確認」的開場，不是「請繼續推進」——硬推下去就是走錯路。

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

當前任務涉及架構設計、模組切分、職責邊界這類決策時，可讀：

- `references/good-architecture-example.md`——本人過去某專案（async + LLM judge 類型）的架構結果，**不是範本**。
  - 每個專案需求不同，這份不是用來照抄，而是看「同等品味之下，設計長什麼樣、決策依據是什麼」。
  - 要模仿的是背後的**取捨節奏**，不是檔案佈局。
