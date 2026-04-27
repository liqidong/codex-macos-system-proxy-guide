#!/usr/bin/env zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -f "$repo_root/.env" ]]; then
  set -a
  source "$repo_root/.env"
  set +a
fi

APP_NAME="${APP_NAME:-Codex}"
SKIP_PROXY_CHECK="${SKIP_PROXY_CHECK:-0}"

if [[ "$SKIP_PROXY_CHECK" != "1" ]]; then
  "$repo_root/scripts/check-system-proxy.sh"
fi

open -a "$APP_NAME"
echo "Opened $APP_NAME using macOS system proxy."

