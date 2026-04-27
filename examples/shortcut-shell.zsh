#!/usr/bin/env zsh

# Paste this into macOS Shortcuts -> Run Shell Script.
# Replace REPO_DIR and the values below.

export REPO_DIR="$HOME/Desktop/codex-proxy-launcher-guide"
export HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
export HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
export ALL_PROXY_URL=""
export APP_EXECUTABLE="/Applications/Codex.app/Contents/MacOS/Codex"
export QUIT_EXISTING="1"

"$REPO_DIR/scripts/launch-codex-with-proxy.sh"
