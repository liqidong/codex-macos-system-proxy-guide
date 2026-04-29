# 仓库地图

这是一套 macOS AI 应用系统代理实践手册。

你会学到：

- 如何理解 VPN、system proxy、TUN、规则模式。
- 如何发现自己的本地代理 host、端口、网络服务和代理组名。
- 如何安全地把 OpenAI / Anthropic 规则放进覆写文件。
- 如何验证 Codex / Claude 流量真的命中目标代理组。

## 推荐顺序

```text
00-overview
01-mental-model
02-discovery
03-from-vpn-to-system-proxy
04-safe-workflow
05-rules-and-overrides
06-macos-system-proxy
apps/codex or apps/claude
clients/clash-verge, if relevant
troubleshooting
```

## 不要跳过发现步骤

教程里的占位符不是答案：

```text
YOUR_LOCAL_PROXY_HOST
YOUR_LOCAL_HTTP_PROXY_PORT
YOUR_PROXY_GROUP_NAME
YOUR_MACOS_NETWORK_SERVICE
```

这些值必须来自你的机器。

## 最小成功路径

```text
scripts/preflight.sh
fill .env
add rules to override file
reload proxy client
enable macOS system proxy
scripts/check-system-proxy.sh
scripts/open-codex.sh or scripts/open-claude.sh
verify connection view
```
