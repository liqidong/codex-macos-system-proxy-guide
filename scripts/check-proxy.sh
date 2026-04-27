#!/usr/bin/env zsh
set -euo pipefail

HTTP_PROXY_URL="${HTTP_PROXY_URL:-}"
TEST_URL="${TEST_URL:-https://chatgpt.com/}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-10}"

if [[ -z "$HTTP_PROXY_URL" ]]; then
  cat >&2 <<'EOF'
Missing HTTP_PROXY_URL.

Example:
  HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" scripts/check-proxy.sh
EOF
  exit 2
fi

echo "Testing proxy:"
echo "  proxy: $HTTP_PROXY_URL"
echo "  url:   $TEST_URL"

curl \
  --proxy "$HTTP_PROXY_URL" \
  --connect-timeout "$TIMEOUT_SECONDS" \
  --max-time "$TIMEOUT_SECONDS" \
  --head \
  --silent \
  --show-error \
  "$TEST_URL" >/dev/null

echo "Proxy test passed."

