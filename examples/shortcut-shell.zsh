#!/usr/bin/env zsh

# Paste this into macOS Shortcuts -> Run Shell Script.
# Replace the values with your own local proxy endpoint.

export HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
export HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
export ALL_PROXY_URL=""
export APP_EXECUTABLE="/Applications/Codex.app/Contents/MacOS/Codex"

osascript -e 'tell application "Codex" to quit' >/dev/null 2>&1
sleep 1

env_vars=(
  "HTTP_PROXY=$HTTP_PROXY_URL"
  "HTTPS_PROXY=$HTTPS_PROXY_URL"
  "http_proxy=$HTTP_PROXY_URL"
  "https_proxy=$HTTPS_PROXY_URL"
  "NO_PROXY=localhost,127.0.0.1,::1"
  "no_proxy=localhost,127.0.0.1,::1"
)

if [[ -n "$ALL_PROXY_URL" ]]; then
  env_vars+=("ALL_PROXY=$ALL_PROXY_URL" "all_proxy=$ALL_PROXY_URL")
fi

nohup env "${env_vars[@]}" "$APP_EXECUTABLE" >/tmp/codex-via-proxy.log 2>&1 &

