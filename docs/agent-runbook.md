# Agent Runbook

This runbook is for another model taking over the task.

The desired setup is:

```text
macOS system proxy: on
proxy client rule mode: on
TUN mode: off
Codex: opened normally
```

Do not use per-app proxy injection as the default path.

## Step 1: Discover local state

Run:

```zsh
scripts/preflight.sh
```

Read the output. You are looking for:

```text
Codex app name
macOS network service
current system proxy state
listening local ports
candidate proxy config files
```

If the script finds more than one plausible proxy port, do not choose randomly. Ask the user which one their proxy client uses.

## Step 2: Fill `.env`

Create `.env` from `.env.example` if this repo needs to set system proxy.

Example shape:

```zsh
NETWORK_SERVICE="Wi-Fi"
PROXY_HOST="127.0.0.1"
PROXY_PORT="YOUR_LOCAL_PROXY_PORT"
ENABLE_SOCKS_PROXY="0"
APP_NAME="Codex"
```

Do not commit `.env`.

## Step 3: Disable TUN

In the proxy client UI, disable settings named like:

```text
TUN
Enhanced mode
Virtual network adapter
Transparent proxy
DNS hijack
Redirect all traffic
```

The purpose is to avoid routing the whole system through a virtual network interface.

## Step 4: Add rules safely

Find the user's rule enhancement, mixin, merge, override, or profile enhancement file.

Before editing:

```zsh
cp "$RULES_TARGET_FILE" "$RULES_TARGET_FILE.bak-$(date +%Y%m%d%H%M%S)"
```

Then add the rules from:

```text
examples/clash-compatible-rules.yaml
```

Replace:

```text
YOUR_PROXY_GROUP_NAME
```

with the real group name from the user's config.

Do not edit generated runtime config as the permanent solution.

## Step 5: Enable system proxy

Preferred path: ask the user to enable system proxy in their proxy client UI.

Script path:

```zsh
scripts/set-system-proxy.sh
```

Only run the script after `.env` is filled.

## Step 6: Test system proxy

Run:

```zsh
scripts/check-system-proxy.sh
```

If it fails:

```text
HTTPEnable/HTTPSEnable not 1 -> system proxy is not enabled
Connection refused -> local proxy is not listening or wrong port
Timeout -> proxy reachable but upstream route may be bad
HTTP 403/404 -> network path may still be OK, test another URL
```

## Step 7: Open Codex

Run:

```zsh
scripts/open-codex.sh
```

This opens Codex normally. It does not inject per-app proxy variables.

## Step 8: Verify traffic

Open the proxy client's connection view.

Look for:

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
statsig.com
featuregates.org
```

If the traffic appears but hits DIRECT, the rule order or group name is wrong.

If no traffic appears, confirm Codex is using macOS system proxy and not bypassing it.

## Step 9: Create a launcher

For a repeatable user-facing launcher, use:

```text
examples/shortcut-shell.zsh
```

or create an Automator App using:

```text
docs/custom-icon.md
```

