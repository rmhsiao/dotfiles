# uv venv 在不支援 symlink 的檔案系統失敗

## 症狀

執行 `uv sync` 或 `uv venv` 時出現：

```
error: Failed to create virtual environment
  Caused by: failed to symlink file from .venv/bin/python to /usr/bin/python3.13: Operation not permitted (os error 1)
```

## 根因

專案目錄位於不支援 symlink 的掛載檔案系統（例如 `/d/` 下的 CIFS/SMB 掛載）。uv 建立 venv 時需在 `.venv/bin/` 內建立指向 Python 執行檔的 symlink，在此類檔案系統上會被 OS 拒絕。

驗證方式：
```bash
ln -s /usr/bin/python3.13 /d/some/path/test_link   # 若回傳 "Permission denied" 即確認
```

## 解法

1. 在支援 symlink 的目錄建立 venv 並完成初始 sync：

```bash
UV_PROJECT_ENVIRONMENT=/home/agent/.venvs/<project-name> uv sync --dev
```

2. 將環境變數寫入 `/etc/sandbox-persistent.sh`，後續所有 `uv run` 自動生效：

```bash
echo 'export UV_PROJECT_ENVIRONMENT=/home/agent/.venvs/<project-name>' >> /etc/sandbox-persistent.sh
```

## 適用環境

沙箱內專案目錄掛載在 `/d/` 下。
