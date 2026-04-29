# macOS AI App System Proxy Guide

把 VPN / 代理客户端的经验整理成一套可复用的方法：在 macOS 上用系统代理让 Codex、Claude 等 AI 应用稳定联网，同时保留规则分流，不依赖 TUN 模式。

这不是“复制某个端口就能用”的教程。每个人的代理客户端、订阅、代理组、端口和网络服务都不同。本仓库教你如何发现自己的值、如何安全改规则、如何验证链路。

## 适合谁

- 你已经有一个本地代理客户端，例如 Clash Verge 或兼容 Clash / Mihomo 配置的客户端。
- 你希望 Codex、Claude、ChatGPT、OpenAI、Anthropic 相关流量走指定代理组。
- 你不想依赖 TUN、虚拟网卡、DNS 劫持来解决 AI 应用联网。
- 你想把配置过程变成可检查、可回滚、可教给别人的流程。

## 核心思路

```text
AI App
  -> macOS system proxy
  -> local proxy client
  -> rule mode
  -> selected proxy group
  -> AI service domains
```

代理客户端仍然负责“哪些域名走哪个代理组”。macOS 系统代理只负责让支持系统代理的 App 进入本地代理客户端。

本仓库默认不走这条路：

```text
AI App
  -> TUN / virtual network adapter
  -> DNS hijack / fake IP
  -> route everything through proxy core
```

TUN 可以解决一些场景，但它更重，影响面更大。这个仓库的目标是先把轻量路径做对。

## 学习路径

1. 先读 [仓库地图](docs/00-overview.md)，了解整体路径。
2. 再读 [系统代理心智模型](docs/01-mental-model.md)，弄清 VPN、系统代理、TUN、规则模式的区别。
3. 读 [从 VPN 经验迁移到 System Proxy](docs/03-from-vpn-to-system-proxy.md)，把经验抽象成可复用流程。
4. 再读 [发现本机配置值](docs/02-discovery.md)，不要猜端口、代理组和网络服务。
5. 修改前读 [安全工作流](docs/04-safe-workflow.md)。
6. 修改规则前读 [规则与覆写文件](docs/05-rules-and-overrides.md)。
7. 启用系统代理前读 [macOS System Proxy](docs/06-macos-system-proxy.md)。
8. 如果你用的是 Clash Verge 或类似客户端，读 [Clash Verge 实战](docs/clients/clash-verge.md)。
9. 配 Codex 时读 [Codex system proxy](docs/apps/codex.md)。
10. 配 Claude 时读 [Claude system proxy](docs/apps/claude.md)。
11. 出问题时读 [排障手册](docs/troubleshooting.md)。

AI agent 接手本仓库时，先读 [AGENTS.md](AGENTS.md)，再按 [agent 执行手册](docs/agent-runbook.md) 操作。

## 快速开始

先做只读检查：

```zsh
scripts/preflight.sh
```

如果你希望本仓库帮你设置 macOS 系统代理，复制并填写本机值：

```zsh
cp .env.example .env
```

必须填写真实值：

```zsh
NETWORK_SERVICE="你的 macOS 网络服务名"
PROXY_HOST="你的本地代理监听地址"
PROXY_PORT="你的本地 HTTP/HTTPS 代理端口"
APP_NAME="Codex 的 App 名称"
CLAUDE_APP_NAME="Claude 的 App 名称"
```

然后验证：

```zsh
scripts/check-system-proxy.sh
```

打开 Codex：

```zsh
scripts/open-codex.sh
```

打开 Claude：

```zsh
scripts/open-claude.sh
```

如果系统代理还没有开启，并且你明确希望这个仓库通过 `networksetup` 修改系统代理：

```zsh
scripts/set-system-proxy.sh
```

## 规则模板

Codex / OpenAI / ChatGPT：

- [examples/openai-rules-prepend.yaml](examples/openai-rules-prepend.yaml)
- [examples/openai-rules-list.yaml](examples/openai-rules-list.yaml)

Claude / Anthropic：

- [examples/anthropic-rules-prepend.yaml](examples/anthropic-rules-prepend.yaml)
- [examples/anthropic-rules-list.yaml](examples/anthropic-rules-list.yaml)

把 `YOUR_PROXY_GROUP_NAME` 替换为你配置里真实存在的代理组名。不要写别人的组名，也不要凭感觉写。

## 安全边界

- 不硬编码代理客户端名称。
- 不硬编码本地代理端口。
- 不硬编码代理组名称。
- 不把 TUN 当成默认方案。
- 不开启 DNS 劫持或虚拟网卡，除非你明确要走那条路。
- 不直接修改远程订阅文件。
- 不把生成出来的运行时配置当成永久配置。
- 修改任何已有代理配置前，先备份。

## 完成标准

一次配置完成，不是“App 能打开”就算结束，而是满足这些条件：

- 代理客户端处于规则模式。
- TUN 关闭。
- macOS 系统代理开启。
- AI 服务域名规则进入非订阅的覆写 / 增强 / mixin 文件。
- `scripts/check-system-proxy.sh` 至少有测试 URL 通过。
- Codex 或 Claude 能通过本仓库脚本打开。
- 代理客户端连接视图里能看到相关域名命中目标代理组。
