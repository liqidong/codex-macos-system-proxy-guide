#!/usr/bin/env zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -f "$repo_root/.env" ]]; then
  set -a
  source "$repo_root/.env"
  set +a
fi

PROXY_HOST="${PROXY_HOST:-}"
PROXY_PORT="${PROXY_PORT:-}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-10}"
TEST_URLS=(${=TEST_URLS:-https://chatgpt.com/ https://openai.com/})
ALLOW_PARTIAL_PROXY_CHECK="${ALLOW_PARTIAL_PROXY_CHECK:-0}"

proxy_dump="$(scutil --proxy)"

echo "macOS system proxy:"
echo "$proxy_dump"

http_enable="$(echo "$proxy_dump" | awk '/HTTPEnable/ {print $3; exit}')"
https_enable="$(echo "$proxy_dump" | awk '/HTTPSEnable/ {print $3; exit}')"
system_host="$(echo "$proxy_dump" | awk '/HTTPProxy/ {print $3; exit}')"
system_port="$(echo "$proxy_dump" | awk '/HTTPPort/ {print $3; exit}')"

if [[ "$http_enable" != "1" || "$https_enable" != "1" ]]; then
  echo "System HTTP/HTTPS proxy is not fully enabled." >&2
  echo "Enable system proxy in your proxy client, or run scripts/set-system-proxy.sh after filling .env." >&2
  exit 1
fi

PROXY_HOST="${PROXY_HOST:-$system_host}"
PROXY_PORT="${PROXY_PORT:-$system_port}"

if [[ -z "$PROXY_HOST" || -z "$PROXY_PORT" ]]; then
  echo "Could not discover system proxy host/port." >&2
  exit 2
fi

proxy_url="http://$PROXY_HOST:$PROXY_PORT"
echo "Testing through system proxy endpoint: $proxy_url"

passed=0
failed=0

for url in "${TEST_URLS[@]}"; do
  echo "  url: $url"
  http_status="$(
    curl \
      --proxy "$proxy_url" \
      --connect-timeout "$TIMEOUT_SECONDS" \
      --max-time "$TIMEOUT_SECONDS" \
      --head \
      --location \
      --silent \
      --show-error \
      --output /dev/null \
      --write-out '%{http_code}' \
      "$url" 2>/tmp/codex-system-proxy-check.err
  )" && rc=0 || rc=$?

  if [[ "$rc" -eq 0 && "$http_status" != "000" ]]; then
    echo "    OK HTTP $http_status"
    passed=$((passed + 1))
  else
    echo "    FAIL curl_exit=$rc http=$http_status"
    sed 's/^/    /' /tmp/codex-system-proxy-check.err >&2 || true
    failed=$((failed + 1))
  fi
done

rm -f /tmp/codex-system-proxy-check.err

echo "Result: $passed passed, $failed failed"

if [[ "$passed" -eq 0 ]]; then
  exit 1
fi

if [[ "$failed" -gt 0 && "$ALLOW_PARTIAL_PROXY_CHECK" != "1" ]]; then
  echo "Some proxy checks failed. Set ALLOW_PARTIAL_PROXY_CHECK=1 only if you intentionally accept partial success." >&2
  exit 1
fi
