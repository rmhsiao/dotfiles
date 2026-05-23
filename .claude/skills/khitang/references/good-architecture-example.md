# 一個好架構長什麼樣（範例）

> **這份是「結果展示」，不是樣板**。
>
> 過往某專案（async + LLM judge 類型的 guardrails 套件）最終收斂出的架構長相，貼在這裡是為了讓你看到——在 khitang 風格之下、面對那個特定需求時、最後選擇了怎樣的職責切分與命名。
>
> **每個專案的需求不同**。下個專案的層次數、分檔方式、命名都會不一樣。重點是學會背後的**取捨節奏與品味**——例如「facade 是否該認識業務」、「組裝邏輯該不該寫進模組本體」——而不是照抄這份檔案佈局。

---

## 範例：某 guardrails 套件

需求脈絡（簡述）：對使用者輸入並行跑多個 LLM judge 模組（prompt injection、denied topic、system leakage），任一被擋下就短路、cancel 其他 task。

收斂後的長相：

```
<pkg>/
├── __init__.py          # 只 re-export 公開介面
├── core.py              # Facade：不含業務邏輯，純組裝 + log
├── config.py            # 頂層 Config，組合各子模組 Config
├── llm_config.py        # 跨模組 config 抽獨立檔（避免 circular import）
├── dto.py               # 純資料傳遞物件
├── enums.py             # StrEnum + property lookup tables
├── orchestrator.py      # 流程控制(並行、短路、cancel、timeout)；不認識業務
└── modules/
    ├── base.py          # ABC、基底 Config、共用例外
    ├── factory.py       # 依 config 建 module 實例
    └── <module>.py      # 一個 module 一個檔，自帶 *Config 與 *Schema
```

---

## 從這個範例學什麼

不是「以後都這樣切」，而是這幾個**取捨判準**——這些才會跨專案重用：

1. **Facade 為何不含邏輯？**
   入口要薄、要穩定。業務變動回流到入口介面，使用者每次升級都會痛。Facade 只做「依 config 組裝出 orchestrator + 註冊 module」這類無腦工作，加 log 就停手。

2. **Orchestrator 為何不認識業務？**
   只處理「並行 / 短路 / cancel / timeout / 彙整」這類**流程**動作。把業務塞進來會讓 orchestrator 跟特定 module 偶合，無法獨立測試或替換。判準：orchestrator 應該換掉所有 module 也能照常跑。

3. **每個 module 為何自包含？**
   `*Config`、output schema、`*Module` class 都放同檔；prompt template / 常數放 module-level。**新增 / 移除 module 只動一個檔**——這是真正的可替換性。若一個 module 散在三五個地方，移除它就要記住三五個位置，可替換性是假的。

4. **Factory 為何單向依賴？**
   Factory 知道所有 module，但 module 不認識 factory。換組裝策略（例如改成 plugin discovery）只動 factory，module 本體不變。

5. **跨模組 config 為何另立檔？**
   若 `LLMConfig` 放 `config.py`，而 `config.py` 又 import 各 module 的 `*Config`，會形成 circular import。當發現此狀況，把共用 config 抽成獨立檔即可——這種拆檔有實際理由，不是潔癖。

---

這些是「在這個情境下我會這樣寫」，不是「以後都這樣寫」。新專案有自己的脈絡——讀完這份後，**請按新專案的需求重新思考分層**，而不是把這份貼上去微調。
