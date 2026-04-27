# Agent Runbook

This runbook is for another model taking over the task.

It is deliberately procedural. Follow it in order.

## Step 1: Discover local state

Run:

```zsh
scripts/preflight.sh
```

Read the output. You are looking for:

```text
Codex executable
listening local ports
system proxy status
candidate proxy config files
```

If the script finds more than one plausible proxy port, do not choose randomly. Ask the user which one their proxy client uses.

## Step 2: Fill `.env`

Create `.env` from `.env.example`.

Example shape:

```zsh
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
ALL_PROXY_URL=""
APP_EXECUTABLE="/Applications/Codex.app/Contents/MacOS/Codex"
```

Do not commit `.env`.

## Step 3: Add rules safely

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

Do not edit generated runtime config unless the user explicitly asks for a temporary test.

## Step 4: Reload config

The user may need to click reload in their proxy client.

If the proxy client exposes a known API and the user approves, use it. Otherwise, tell the user exactly what to click.

Do not restart the whole proxy app unless necessary. It can briefly interrupt the user's network.

## Step 5: Test proxy

Run:

```zsh
scripts/check-proxy.sh
```

If `.env` exists, the script reads it automatically.

If it fails:

```text
Connection refused -> local proxy is not listening or wrong port
Timeout -> proxy reachable but upstream route may be bad
HTTP 403/404 -> network path may still be OK, check another TEST_URL
DNS error -> local proxy or DNS mode may be wrong
```

## Step 6: Launch Codex

Run:

```zsh
scripts/launch-codex-with-proxy.sh
```

By default it does not quit an existing Codex session. To force a clean restart:

```zsh
QUIT_EXISTING=1 scripts/launch-codex-with-proxy.sh
```

## Step 7: Verify traffic

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

If no traffic appears, Codex may not have inherited the proxy settings. Re-run with:

```zsh
USE_ELECTRON_PROXY_ARGS=1 scripts/launch-codex-with-proxy.sh
```

## Step 8: Create a launcher

For a repeatable user-facing launcher, use:

```text
examples/shortcut-shell.zsh
```

or create an Automator App using:

```text
docs/custom-icon.md
```

The shortcut should call the repository script. Do not duplicate the full launch logic.

