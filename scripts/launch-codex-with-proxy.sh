#!/usr/bin/env zsh
set -euo pipefail

APP_NAME="${APP_NAME:-Codex}"
APP_EXECUTABLE="${APP_EXECUTABLE:-/Applications/Codex.app/Contents/MacOS/Codex}"
HTTP_PROXY_URL="${HTTP_PROXY_URL:-}"
HTTPS_PROXY_URL="${HTTPS_PROXY_URL:-$HTTP_PROXY_URL}"
ALL_PROXY_URL="${ALL_PROXY_URL:-}"
NO_PROXY_LIST="${NO_PROXY_LIST:-localhost,127.0.0.1,::1}"
QUIT_EXISTING="${QUIT_EXISTING:-1}"
LOG_FILE="${LOG_FILE:-/tmp/codex-via-proxy.log}"

if [[ -z "$HTTP_PROXY_URL" ]]; then
  cat >&2 <<'EOF'
Missing HTTP_PROXY_URL.

Example:
  HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
  HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
  scripts/launch-codex-with-proxy.sh

Optional:
  ALL_PROXY_URL="socks5://127.0.0.1:YOUR_LOCAL_SOCKS_PORT"
EOF
  exit 2
fi

if [[ ! -x "$APP_EXECUTABLE" ]]; then
  echo "Codex executable not found or not executable: $APP_EXECUTABLE" >&2
  echo "Set APP_EXECUTABLE to your Codex binary path." >&2
  exit 3
fi

if [[ "$QUIT_EXISTING" != "0" ]]; then
  osascript -e "tell application \"$APP_NAME\" to quit" >/dev/null 2>&1 || true
  sleep 1
fi

env_vars=(
  "HTTP_PROXY=$HTTP_PROXY_URL"
  "HTTPS_PROXY=$HTTPS_PROXY_URL"
  "http_proxy=$HTTP_PROXY_URL"
  "https_proxy=$HTTPS_PROXY_URL"
  "NO_PROXY=$NO_PROXY_LIST"
  "no_proxy=$NO_PROXY_LIST"
)

if [[ -n "$ALL_PROXY_URL" ]]; then
  env_vars+=("ALL_PROXY=$ALL_PROXY_URL" "all_proxy=$ALL_PROXY_URL")
fi

nohup env "${env_vars[@]}" "$APP_EXECUTABLE" >"$LOG_FILE" 2>&1 &

echo "Started $APP_NAME through local proxy."
echo "Log: $LOG_FILE"

