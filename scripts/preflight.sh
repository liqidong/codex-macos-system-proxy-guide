#!/usr/bin/env zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -f "$repo_root/.env" ]]; then
  set -a
  source "$repo_root/.env"
  set +a
fi

print_section() {
  printf '\n== %s ==\n' "$1"
}

print_section "Platform"
sw_vers 2>/dev/null || true
uname -a

print_section "Codex"
app_name="${APP_NAME:-}"
if [[ -n "$app_name" && -d "/Applications/$app_name.app" ]]; then
  echo "APP_NAME=$app_name"
  echo "APP_PATH=/Applications/$app_name.app"
elif [[ -n "$app_name" && -d "$HOME/Applications/$app_name.app" ]]; then
  echo "APP_NAME=$app_name"
  echo "APP_PATH=$HOME/Applications/$app_name.app"
else
  echo "APP_NAME=${APP_NAME:-MISSING}"
  find /Applications "$HOME/Applications" -maxdepth 2 -name '*Codex*.app' -print 2>/dev/null || true
fi

print_section "Claude"
claude_app_name="${CLAUDE_APP_NAME:-}"
if [[ -n "$claude_app_name" && -d "/Applications/$claude_app_name.app" ]]; then
  echo "CLAUDE_APP_NAME=$claude_app_name"
  echo "CLAUDE_APP_PATH=/Applications/$claude_app_name.app"
elif [[ -n "$claude_app_name" && -d "$HOME/Applications/$claude_app_name.app" ]]; then
  echo "CLAUDE_APP_NAME=$claude_app_name"
  echo "CLAUDE_APP_PATH=$HOME/Applications/$claude_app_name.app"
else
  echo "CLAUDE_APP_NAME=${CLAUDE_APP_NAME:-MISSING}"
  find /Applications "$HOME/Applications" -maxdepth 2 -name '*Claude*.app' -print 2>/dev/null || true
fi

print_section "Proxy environment"
echo "NETWORK_SERVICE=${NETWORK_SERVICE:-MISSING}"
echo "PROXY_HOST=${PROXY_HOST:-MISSING}"
echo "PROXY_PORT=${PROXY_PORT:-MISSING}"
echo "ENABLE_SOCKS_PROXY=${ENABLE_SOCKS_PROXY:-0}"

print_section "Listening local ports"
if command -v lsof >/dev/null 2>&1; then
  lsof -nP -iTCP@127.0.0.1 -sTCP:LISTEN 2>/dev/null | sed -n '1,80p'
else
  echo "lsof not found"
fi

print_section "macOS system proxy"
if command -v scutil >/dev/null 2>&1; then
  scutil --proxy
  http_enabled="$(scutil --proxy | awk '/HTTPEnable/ {print $3; exit}')"
  https_enabled="$(scutil --proxy | awk '/HTTPSEnable/ {print $3; exit}')"
  if [[ "$http_enabled" == "1" || "$https_enabled" == "1" ]]; then
    echo "SYSTEM_PROXY_HINT=system proxy is enabled; this is the preferred path for this guide"
  else
    echo "SYSTEM_PROXY_HINT=system proxy is disabled; enable it in your proxy client or run scripts/set-system-proxy.sh after filling .env"
  fi
else
  echo "scutil not found"
fi

print_section "Candidate proxy config files"
candidate_roots=(
  "$HOME/Library/Application Support"
  "$HOME/.config"
  "$HOME/.proxy"
)

for root in "${candidate_roots[@]}"; do
  [[ -d "$root" ]] || continue
  find "$root" -maxdepth 4 \
    \( -iname '*clash*' -o -iname '*mihomo*' -o -iname '*verge*' -o -iname '*proxy*' \) \
    -print 2>/dev/null | sed -n '1,80p'
done

print_section "Next action"
cat <<'EOF'
Fill missing values in .env if you want this repo to set system proxy, then run:

  scripts/check-system-proxy.sh
  scripts/open-codex.sh

If multiple local proxy ports are listed, do not guess. Ask the user which one belongs to their proxy client.
Keep TUN disabled for this workflow.
EOF
