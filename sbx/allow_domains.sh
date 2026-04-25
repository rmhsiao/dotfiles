
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAINS_FILE="$SCRIPT_DIR/allowed_domains.txt"

domains=$(grep -v '^\s*#' "$DOMAINS_FILE" | grep -v '^\s*$' | paste -sd ',')

sbx policy allow network "$domains"
