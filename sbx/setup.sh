# 取得腳本所在的資料夾路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/envs.rc"
cat "$SCRIPT_DIR/envs.rc" >> /etc/sandbox-persistent.sh

ln -sf "$SCRIPT_DIR/../claude/skills" ~/.claude/skills

git config --global user.name "rmhsiao"
git config --global user.email "rumao8341@gmail.com"
