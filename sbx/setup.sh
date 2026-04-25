
# ===== 環境參數設定 =====

# 取得腳本所在的資料夾路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/envs.rc"
cat "$SCRIPT_DIR/envs.rc" >> /etc/sandbox-persistent.sh


# ===== 符號連結 =====

setup_symlinks() {
  for link in "$@"; do
    ln -s "$SCRIPT_DIR/../.claude/$link" ~/.claude/"$link" || echo "[skip] ~/.claude/$link 已存在或無法建立軟連結"
  done
}

setup_symlinks "skills" "settings.json" "plugins" "projects"


# ===== git =====

git config --global user.name "rmhsiao"
git config --global user.email "rumao8341@gmail.com"


# ===== uv =====
curl -LsSf https://astral.sh/uv/install.sh | sh


# ===== bun =====

curl -fsSL https://bun.sh/install | bash

# 讓 claude 的 sub process shell 也能存取到 bun
sudo ln -sf /home/agent/.bun/bin/bun /usr/local/bin/bun
