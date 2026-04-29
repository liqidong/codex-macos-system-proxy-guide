#!/usr/bin/env zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -f "$repo_root/.env" ]]; then
  set -a
  source "$repo_root/.env"
  set +a
fi

CLAUDE_APP_NAME="${CLAUDE_APP_NAME:-}"
SKIP_PROXY_CHECK="${SKIP_PROXY_CHECK:-0}"
CLAUDE_TEST_URLS="${CLAUDE_TEST_URLS:-https://claude.ai/ https://claude.com/ https://www.anthropic.com/}"

if [[ -z "$CLAUDE_APP_NAME" ]]; then
  cat >&2 <<'EOF'
Missing CLAUDE_APP_NAME.

Set CLAUDE_APP_NAME in .env to the exact macOS application name for Claude.
EOF
  exit 2
fi

if [[ "$SKIP_PROXY_CHECK" != "1" ]]; then
  TEST_URLS="$CLAUDE_TEST_URLS" "$repo_root/scripts/check-system-proxy.sh"
fi

open -a "$CLAUDE_APP_NAME"
echo "Opened $CLAUDE_APP_NAME using macOS system proxy."
