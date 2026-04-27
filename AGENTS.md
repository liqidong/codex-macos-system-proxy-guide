# AI Operator Guide

This repository is meant to be operated by humans and AI agents.

Your job is to adapt the templates to the current user's machine without guessing local values.

## Non-negotiable rules

- Do not hardcode a proxy client name.
- Do not hardcode a local proxy port.
- Do not hardcode a proxy group name.
- Do not edit remote subscription files directly.
- Do not delete user configuration files.
- Always create a backup before editing any existing proxy configuration.
- If you cannot discover a required value, stop and ask the user for that value.

## Required values

Before changing anything, identify:

```text
HTTP_PROXY_URL         Local HTTP or mixed proxy URL.
HTTPS_PROXY_URL        Usually the same as HTTP_PROXY_URL.
ALL_PROXY_URL          Optional SOCKS URL.
APP_EXECUTABLE         Codex executable path.
YOUR_PROXY_GROUP_NAME  Real proxy group name in the user's proxy config.
RULES_TARGET_FILE      Rule enhancement / override file to edit.
```

Never invent these values.

## Safe operating sequence

1. Run `scripts/preflight.sh`.
2. Read the output and identify missing values.
3. If required values are missing, ask the user. Do not guess.
4. Back up `RULES_TARGET_FILE` before editing it.
5. Add rules from `examples/clash-compatible-rules.yaml`, replacing `YOUR_PROXY_GROUP_NAME`.
6. Ask the user to reload their proxy client, or use their client-specific reload command only if already known.
7. Run `scripts/check-proxy.sh`.
8. Start Codex through `scripts/launch-codex-with-proxy.sh`.
9. Verify traffic in the proxy client's connection view or logs.

## What to edit

Safe to edit:

```text
.env
RULES_TARGET_FILE, after backup
macOS Shortcut or Automator wrapper created by the user
```

Do not edit:

```text
Remote subscription profile
Generated runtime config
System network proxy settings, unless the user explicitly asks for system-wide proxy
```

## Stop conditions

Stop and ask the user when:

- There are multiple possible local proxy ports.
- The proxy group name is unclear.
- The proxy client has no rule enhancement or override file.
- Editing the only visible config would modify a remote subscription file directly.
- Codex is already running and `QUIT_EXISTING=1` would interrupt the user's current work.

## Success criteria

The job is complete when:

- Required rules are added to a non-subscription override location.
- The proxy config is reloaded or the user is told exactly how to reload it.
- `scripts/check-proxy.sh` succeeds with the user's `HTTP_PROXY_URL`.
- Codex is launched through `scripts/launch-codex-with-proxy.sh`.
- The proxy client shows OpenAI / ChatGPT related traffic hitting the selected proxy group.

