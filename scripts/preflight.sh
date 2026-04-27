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
app_executable="${APP_EXECUTABLE:-/Applications/Codex.app/Contents/MacOS/Codex}"
if [[ -x "$app_executable" ]]; then
  echo "APP_EXECUTABLE=$app_executable"
else
  echo "APP_EXECUTABLE_MISSING=$app_executable"
  find /Applications "$HOME/Applications" -maxdepth 3 -path '*Codex.app/Contents/MacOS/Codex' -print 2>/dev/null || true
fi

print_section "Proxy environment"
echo "HTTP_PROXY_URL=${HTTP_PROXY_URL:-MISSING}"
echo "HTTPS_PROXY_URL=${HTTPS_PROXY_URL:-MISSING}"
echo "ALL_PROXY_URL=${ALL_PROXY_URL:-OPTIONAL_EMPTY}"

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
    echo "SYSTEM_PROXY_HINT=system proxy is enabled, but this repo still needs HTTP_PROXY_URL in .env for app-specific launch"
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
Fill missing values in .env, then run:

  scripts/check-proxy.sh
  scripts/launch-codex-with-proxy.sh

If multiple local proxy ports are listed, do not guess. Ask the user which one belongs to their proxy client.
EOF
