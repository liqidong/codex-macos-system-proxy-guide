#!/usr/bin/env zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -f "$repo_root/.env" ]]; then
  set -a
  source "$repo_root/.env"
  set +a
fi

HTTP_PROXY_URL="${HTTP_PROXY_URL:-}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-10}"
TEST_URLS=(${=TEST_URLS:-https://chatgpt.com/ https://openai.com/ https://github.com/})

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

passed=0
failed=0

for url in "${TEST_URLS[@]}"; do
  echo "  url:   $url"
  status="$(
    curl \
      --proxy "$HTTP_PROXY_URL" \
      --connect-timeout "$TIMEOUT_SECONDS" \
      --max-time "$TIMEOUT_SECONDS" \
      --head \
      --location \
      --silent \
      --show-error \
      --output /dev/null \
      --write-out '%{http_code}' \
      "$url" 2>/tmp/codex-proxy-check.err
  )" && rc=0 || rc=$?

  if [[ "$rc" -eq 0 && "$status" != "000" ]]; then
    echo "    OK HTTP $status"
    passed=$((passed + 1))
  else
    echo "    FAIL curl_exit=$rc http=$status"
    sed 's/^/    /' /tmp/codex-proxy-check.err >&2 || true
    failed=$((failed + 1))
  fi
done

rm -f /tmp/codex-proxy-check.err

echo "Result: $passed passed, $failed failed"

if [[ "$passed" -eq 0 ]]; then
  exit 1
fi
