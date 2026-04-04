# 取得腳本所在的資料夾路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/envs.rc"
cat "$SCRIPT_DIR/envs.rc" >> /etc/sandbox-persistent.sh

ln -s "$SCRIPT_DIR/../claude/skills" ~/.claude/skills || echo "[skip] ~/.claude/skills 已存在或無法建立軟連結"

git config --global user.name "rmhsiao"
git config --global user.email "rumao8341@gmail.com"
