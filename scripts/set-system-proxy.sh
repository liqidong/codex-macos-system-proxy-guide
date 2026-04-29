#!/usr/bin/env zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -f "$repo_root/.env" ]]; then
  set -a
  source "$repo_root/.env"
  set +a
fi

NETWORK_SERVICE="${NETWORK_SERVICE:-}"
PROXY_HOST="${PROXY_HOST:-}"
PROXY_PORT="${PROXY_PORT:-}"
ENABLE_SOCKS_PROXY="${ENABLE_SOCKS_PROXY:-0}"
DISABLE_SOCKS_PROXY="${DISABLE_SOCKS_PROXY:-0}"
SOCKS_PROXY_HOST="${SOCKS_PROXY_HOST:-$PROXY_HOST}"
SOCKS_PROXY_PORT="${SOCKS_PROXY_PORT:-$PROXY_PORT}"

if [[ -z "$NETWORK_SERVICE" || -z "$PROXY_HOST" || -z "$PROXY_PORT" ]]; then
  cat >&2 <<'EOF'
Missing NETWORK_SERVICE, PROXY_HOST, or PROXY_PORT.

Create .env from .env.example and fill:
  NETWORK_SERVICE="YOUR_MACOS_NETWORK_SERVICE"
  PROXY_HOST="YOUR_LOCAL_PROXY_HOST"
  PROXY_PORT="YOUR_LOCAL_HTTP_PROXY_PORT"
EOF
  exit 2
fi

if ! networksetup -listallnetworkservices | sed 's/^\*//' | grep -Fxq "$NETWORK_SERVICE"; then
  echo "Network service not found: $NETWORK_SERVICE" >&2
  echo "Available services:" >&2
  networksetup -listallnetworkservices >&2
  exit 3
fi

networksetup -setwebproxy "$NETWORK_SERVICE" "$PROXY_HOST" "$PROXY_PORT"
networksetup -setsecurewebproxy "$NETWORK_SERVICE" "$PROXY_HOST" "$PROXY_PORT"
networksetup -setwebproxystate "$NETWORK_SERVICE" on
networksetup -setsecurewebproxystate "$NETWORK_SERVICE" on

if [[ "$ENABLE_SOCKS_PROXY" == "1" ]]; then
  if [[ -z "$SOCKS_PROXY_HOST" || -z "$SOCKS_PROXY_PORT" ]]; then
    echo "ENABLE_SOCKS_PROXY=1 but SOCKS_PROXY_HOST or SOCKS_PROXY_PORT is missing." >&2
    exit 4
  fi
  networksetup -setsocksfirewallproxy "$NETWORK_SERVICE" "$SOCKS_PROXY_HOST" "$SOCKS_PROXY_PORT"
  networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" on
elif [[ "$DISABLE_SOCKS_PROXY" == "1" ]]; then
  networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" off
else
  echo "Leaving SOCKS system proxy state unchanged."
fi

echo "System proxy enabled for $NETWORK_SERVICE -> $PROXY_HOST:$PROXY_PORT"
echo "Keep TUN disabled in your proxy client for this workflow."
