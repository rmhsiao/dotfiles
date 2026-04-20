
# ===== 環境參數設定 =====

# 取得腳本所在的資料夾路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/envs.rc"
cat "$SCRIPT_DIR/envs.rc" >> /etc/sandbox-persistent.sh

ln -s "$SCRIPT_DIR/../claude/skills" ~/.claude/skills || echo "[skip] ~/.claude/skills 已存在或無法建立軟連結"


# ===== git =====

git config --global user.name "rmhsiao"
git config --global user.email "rumao8341@gmail.com"


# ===== uv =====
curl -LsSf https://astral.sh/uv/install.sh | sh


# ===== bun =====

curl -fsSL https://bun.sh/install | bash

# 讓 claude 的 sub process shell 也能存取到 bun
sudo ln -sf /home/agent/.bun/bin/bun /usr/local/bin/bun
