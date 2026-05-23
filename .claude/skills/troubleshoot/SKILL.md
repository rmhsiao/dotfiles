---
name: troubleshoot
description: This skill should be used when the user asks to "troubleshoot", "look up a known issue", "check if this is a known problem", "add a new issue to troubleshooting", "document this bug", or encounters an error and wants to check past solutions. Use when diagnosing environment, tooling, or workflow problems.
version: 0.1.0
---

# Troubleshooting

已知問題索引，每份 `references/` 檔案記錄一個坑的症狀、根因與解法。

## 已知問題索引

| 檔案 | 簡介 |
|------|------|
| [`references/uv-venv-no-symlink.md`](references/uv-venv-no-symlink.md) | `uv sync` / `uv venv` 在 `/d/` 等不支援 symlink 的掛載檔案系統上失敗（`Operation not permitted`），需透過 `UV_PROJECT_ENVIRONMENT` 將 venv 移至 `/home/agent/.venvs/` |
| [`references/git-commit-msg-buffer-leak.md`](references/git-commit-msg-buffer-leak.md) | commit message 尾端被附加前一筆 commit 的內容（subject 變成 `<新訊息><舊訊息尾段>`），邊界可能出現 `¾` `¤` `¹` 等亂碼。根因是 sandbox overlay fs 不 honour `.git/COMMIT_EDITMSG` 的 truncate-on-write，新短訊息只覆蓋前 N byte、舊內容尾段殘留 |

## 新增問題的格式

在 `references/` 建立新檔案，命名使用 kebab-case 並反映問題主題（例如 `tool-error-context.md`）。檔案結構：

```markdown
# 問題標題

## 症狀
## 根因
## 解法
## 適用環境
```

新增後，在本檔案的「已知問題索引」表格補上一行。
