# Codex macOS System Proxy Guide

Use Codex on macOS through the system proxy, with rule-based routing and TUN disabled.

中文目标：

- 使用 macOS 系统代理完成 Codex 联网。
- 代理客户端使用规则模式。
- OpenAI / ChatGPT / Codex 相关域名走指定代理组。
- 不使用 TUN 模式。
- 避免 TUN / 虚拟网卡 / DNS 劫持带来的系统卡顿、发热、网络不稳定。
- 不绑定任何具体代理客户端、订阅、节点、端口。

如果你是 AI agent，先读：

[AGENTS.md](AGENTS.md)

然后按这个执行手册走：

[docs/agent-runbook.md](docs/agent-runbook.md)

## Why This Exists

Some users only need Codex, ChatGPT, and OpenAI traffic to route correctly.

TUN mode can work, but it is heavier. It installs a virtual network path, may hijack DNS, and can affect the whole system. On some Macs this causes lag, high CPU, broken local network behavior, or browser weirdness.

This guide uses the simpler path:

```text
Codex App
  -> macOS system proxy
  -> local proxy client
  -> rule mode
  -> OpenAI / ChatGPT domains use the selected proxy group
```

The proxy client still does the routing. macOS system proxy only decides how supported apps enter the proxy client.

## Recommended State

Use this as the target state:

```text
Proxy client: running
Mode: rule / rules / rule-based
System proxy: enabled
TUN mode: disabled
Codex: launched normally, or via the shortcut in this repo
```

Do not use this as the default:

```text
TUN mode: enabled
DNS hijack: enabled
Fake-IP required for all traffic
```

Fake-IP or enhanced DNS can be useful for TUN mode. This guide does not depend on it.

## Required Values

You need to discover these on the user's machine:

```text
YOUR_PROXY_GROUP_NAME   Real proxy group name in the proxy config.
PROXY_HOST              Local system proxy host, usually 127.0.0.1.
PROXY_PORT              Local system proxy port from the user's client.
NETWORK_SERVICE         macOS network service, usually Wi-Fi.
APP_NAME                Codex app name, usually Codex.
```

Do not copy values from another machine.

## Quick Start

```zsh
scripts/preflight.sh
cp .env.example .env
# edit .env
scripts/check-system-proxy.sh
scripts/open-codex.sh
```

If system proxy is not enabled yet and the user wants this repo to set it:

```zsh
scripts/set-system-proxy.sh
scripts/check-system-proxy.sh
scripts/open-codex.sh
```

The scripts read `.env` automatically.

## 1. Add Rules Without Breaking Subscription Updates

Do not directly edit a remote subscription file.

Do not directly edit a generated runtime config.

Use the proxy client's rule enhancement, override, mixin, merge, or profile enhancement file.

Rule enhancement example:

[examples/clash-compatible-rules.yaml](examples/clash-compatible-rules.yaml)

Plain rules list example:

[examples/rules-list-only.yaml](examples/rules-list-only.yaml)

Core rules:

```yaml
prepend:
  - DOMAIN-SUFFIX,openai.com,YOUR_PROXY_GROUP_NAME
  - DOMAIN-SUFFIX,chatgpt.com,YOUR_PROXY_GROUP_NAME
  - DOMAIN-SUFFIX,oaistatic.com,YOUR_PROXY_GROUP_NAME
  - DOMAIN-SUFFIX,oaiusercontent.com,YOUR_PROXY_GROUP_NAME
  - DOMAIN-SUFFIX,auth.openai.com,YOUR_PROXY_GROUP_NAME
  - DOMAIN-SUFFIX,statsig.com,YOUR_PROXY_GROUP_NAME
  - DOMAIN-SUFFIX,featuregates.org,YOUR_PROXY_GROUP_NAME
```

The most important rule:

```yaml
- DOMAIN-SUFFIX,chatgpt.com,YOUR_PROXY_GROUP_NAME
```

Rule order matters. These rules should appear before broad `DIRECT`, `GEOIP`, or `MATCH` rules.

Back up before editing:

```zsh
cp "$RULES_TARGET_FILE" "$RULES_TARGET_FILE.bak-$(date +%Y%m%d%H%M%S)"
```

After editing, reload the proxy client config.

## 2. Disable TUN Mode

In the proxy client, turn off settings named like:

```text
TUN
Enhanced mode
Virtual network adapter
Transparent proxy
DNS hijack
Redirect all traffic
```

Names vary by client. The goal is simple: do not route the whole system through a virtual network interface.

This solves the common failure mode:

```text
TUN enabled
  -> all traffic enters the proxy core
  -> DNS may be hijacked
  -> browser, sync, local network, or system services slow down
```

For Codex, system proxy is usually enough.

## 3. Enable macOS System Proxy

You can enable system proxy from the proxy client UI.

If you want to set it from this repo, fill `.env` first:

```zsh
cp .env.example .env
```

Example shape:

```zsh
NETWORK_SERVICE="Wi-Fi"
PROXY_HOST="127.0.0.1"
PROXY_PORT="YOUR_LOCAL_PROXY_PORT"
ENABLE_SOCKS_PROXY="0"
```

Then run:

```zsh
scripts/set-system-proxy.sh
```

This sets HTTP and HTTPS system proxy for the selected macOS network service.

## 4. Open Codex

Once system proxy is enabled, Codex can be opened normally:

```zsh
open -a Codex
```

This repo provides a small wrapper:

```zsh
scripts/open-codex.sh
```

It checks that system proxy is enabled, then opens Codex.

No per-app proxy injection is required.

## 5. Create a Shortcut

Open macOS Shortcuts:

```text
New Shortcut -> Run Shell Script
```

Shell:

```text
/bin/zsh
```

Use:

[examples/shortcut-shell.zsh](examples/shortcut-shell.zsh)

Replace:

```zsh
REPO_DIR="$HOME/Desktop/codex-macos-system-proxy-guide"
```

Then name the shortcut:

```text
Codex System Proxy
```

You can pin it to the menu bar or add it to the Dock.

## 6. Custom Icon

See:

[docs/custom-icon.md](docs/custom-icon.md)

Recommended app name:

```text
Codex System Proxy.app
```

## 7. Verify

Run:

```zsh
scripts/check-system-proxy.sh
```

Then open Codex:

```zsh
scripts/open-codex.sh
```

In the proxy client's connection view, look for:

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
statsig.com
featuregates.org
```

They should hit `YOUR_PROXY_GROUP_NAME`.

## Common Cases

### Case A: System proxy is on, TUN is off

This is the preferred setup.

```text
System proxy: on
Rule mode: on
TUN: off
Codex: open normally
```

### Case B: System proxy is on, but rules do not work

Check:

```text
Proxy group name is real
Rules are before DIRECT / GEOIP / MATCH
Proxy client config was reloaded
Proxy client is in rule mode
```

### Case C: TUN fixes one app but makes the system lag

Use system proxy for Codex instead.

This keeps the network path smaller:

```text
Codex -> macOS system proxy -> proxy client -> rule mode
```

## Publish to GitHub

Before publishing:

```zsh
git status --short
git ls-files .env
```

The second command should print nothing.

With GitHub CLI:

```zsh
gh repo create codex-macos-system-proxy-guide --public --source=. --remote=origin --push
```

Or create an empty GitHub repo first:

```zsh
git remote add origin git@github.com:YOUR_NAME/codex-macos-system-proxy-guide.git
git branch -M main
git push -u origin main
```

## Suggested GitHub Topics

Use these topics so people can find the repo:

```text
codex
openai
chatgpt
macos
system-proxy
proxy
clash-compatible
no-tun
rule-mode
```

## Repository Structure

```text
.
├── .env.example
├── AGENTS.md
├── README.md
├── docs
│   ├── agent-runbook.md
│   ├── custom-icon.md
│   └── troubleshooting.md
├── examples
│   ├── clash-compatible-rules.yaml
│   ├── rules-list-only.yaml
│   └── shortcut-shell.zsh
└── scripts
    ├── check-system-proxy.sh
    ├── open-codex.sh
    ├── preflight.sh
    └── set-system-proxy.sh
```
