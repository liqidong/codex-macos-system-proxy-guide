# AI Operator Guide

This repository is meant to be operated by humans and AI agents.

Goal: teach humans and AI agents how to make Codex, Claude, and similar AI apps work through macOS system proxy, with rule-based routing, without TUN mode as the default workflow.

## Non-negotiable rules

- Do not hardcode a proxy client name.
- Do not hardcode a local proxy port.
- Do not hardcode a proxy group name.
- Do not use TUN mode for this workflow.
- Do not enable DNS hijack or virtual network adapter mode unless the user explicitly asks.
- Do not edit remote subscription files directly.
- Do not edit generated runtime configs as the permanent solution.
- Always create a backup before editing any existing proxy configuration.
- If you cannot discover a required value, stop and ask the user.

## Required values

Before changing anything, identify:

```text
PROXY_HOST              Local system proxy host.
PROXY_PORT              Local system proxy port from the user's client.
NETWORK_SERVICE         Real macOS network service name.
YOUR_PROXY_GROUP_NAME   Real proxy group name in the user's proxy config.
RULES_TARGET_FILE       Rule enhancement / override file to edit.
APP_NAME                Real Codex app name, when configuring Codex.
CLAUDE_APP_NAME         Real Claude app name, when configuring Claude.
```

Never invent these values.

## Safe operating sequence

1. Run `scripts/preflight.sh`.
2. Read the output and identify missing values.
3. If required values are missing, ask the user. Do not guess.
4. Confirm the proxy client is in rule mode.
5. Confirm TUN mode is disabled.
6. Back up `RULES_TARGET_FILE` before editing it.
7. Add app-specific rules from `examples/`, replacing `YOUR_PROXY_GROUP_NAME`.
8. Ask the user to reload their proxy client, or use a known client-specific reload command only if already verified.
9. Enable macOS system proxy through the proxy client UI, or run `scripts/set-system-proxy.sh` after `.env` is filled.
10. Run `scripts/check-system-proxy.sh`.
11. Run `scripts/open-codex.sh` or `scripts/open-claude.sh`.
12. Verify traffic in the proxy client's connection view or logs.

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
Generated runtime config as permanent config
System network proxy settings, unless the user explicitly wants this repo to set system proxy
```

## Stop conditions

Stop and ask the user when:

- There are multiple possible local proxy ports.
- The proxy group name is unclear.
- The proxy client has no rule enhancement or override file.
- Editing the only visible config would modify a remote subscription file directly.
- TUN mode appears to be required by the user's proxy client.
- Enabling system proxy would affect other apps and the user has not agreed to that.

## Success criteria

The job is complete when:

- TUN mode is off.
- The proxy client is in rule mode.
- macOS system proxy is enabled.
- Required rules are added to a non-subscription override location.
- `scripts/check-system-proxy.sh` succeeds.
- Codex or Claude opens normally through the matching script.
- The proxy client shows OpenAI / ChatGPT / Anthropic related traffic hitting the selected proxy group.
