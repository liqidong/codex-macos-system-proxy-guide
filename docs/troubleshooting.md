# 排障手册

排障顺序很重要：先查系统代理，再查规则，再查 App。

## 一键检查

```zsh
scripts/check-system-proxy.sh
```

如果这个脚本完全不通，先不要改 Codex 或 Claude。

## 系统代理没有开启

查看：

```zsh
scutil --proxy
```

你希望看到 HTTP 和 HTTPS 都启用：

```text
HTTPEnable : 1
HTTPSEnable : 1
```

优先在代理客户端 UI 中打开 system proxy。只有你明确想让本仓库修改系统网络设置时，才运行：

```zsh
scripts/set-system-proxy.sh
```

## `.env` 缺值

脚本不会替你猜这些值：

```text
NETWORK_SERVICE
PROXY_HOST
PROXY_PORT
APP_NAME
CLAUDE_APP_NAME
```

运行：

```zsh
scripts/preflight.sh
```

如果还是无法确认，停下来问使用者。

## 检查脚本部分失败

`scripts/check-system-proxy.sh` 默认要求所有测试 URL 都通过。因为 AI 场景里，一个普通网站能通并不能证明 OpenAI 或 Claude 相关域名能通。

只有你明确接受部分成功时，才临时使用：

```zsh
ALLOW_PARTIAL_PROXY_CHECK=1 scripts/check-system-proxy.sh
```

## 本地端口不通

症状：

```text
Connection refused
curl: (7)
```

可能原因：

- 代理客户端没有运行。
- `.env` 里填的是 SOCKS 端口，但脚本按 HTTP proxy 测试。
- 端口来自别的程序。
- 客户端监听在另一个 host。

不要直接换成网上常见端口。先从客户端设置或 `scutil --proxy` 里确认。

## 测试 URL 超时

症状：

```text
Operation timed out
HTTP 000
```

可能原因：

- 本地代理端口存在，但上游节点不可用。
- AI 域名规则没有命中正确代理组。
- 代理客户端没有处于规则模式。
- 当前网络阻断了上游连接。

打开代理客户端连接视图，确认请求是否出现，以及命中哪个策略。

## 规则没有命中代理组

检查：

```text
1. YOUR_PROXY_GROUP_NAME 是否替换成真实组名。
2. 规则是否位于 DIRECT / GEOIP / MATCH 之前。
3. 客户端是否已重新加载配置。
4. 你编辑的是否是覆写文件，而不是无效的临时文件。
```

## TUN 还开着

关闭这些能力：

```text
TUN
Virtual Adapter
Transparent Proxy
DNS Hijack
Redirect All Traffic
```

本仓库不是说 TUN 永远不能用，而是本流程不依赖 TUN。为了排障清晰，先把它关掉。

## Codex 或 Claude 打开后无流量

可能原因：

- App 在系统代理开启前已经启动。
- App 复用了旧 session。
- App 名称填错，脚本打开了错误目标或没有打开。

尝试完全退出 App，再运行：

```zsh
scripts/open-codex.sh
scripts/open-claude.sh
```

## 系统代理影响其他 App

这是预期行为。系统代理是 macOS 网络服务级设置，所有尊重系统代理的 App 都可能受影响。

如果你不接受这个影响，不要继续用系统代理路径；需要另行评估 per-app 方案或其他隔离方式。

## SOCKS 系统代理被保留

`scripts/set-system-proxy.sh` 默认只设置 HTTP / HTTPS 系统代理，不会关闭已有 SOCKS 系统代理。

如果你明确要关闭 SOCKS：

```zsh
DISABLE_SOCKS_PROXY=1 scripts/set-system-proxy.sh
```

如果你明确要设置 SOCKS：

```zsh
ENABLE_SOCKS_PROXY=1 scripts/set-system-proxy.sh
```

## 回滚系统代理

把 `NETWORK_SERVICE` 换成你的真实网络服务名：

```zsh
networksetup -setwebproxystate "$NETWORK_SERVICE" off
networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off
networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" off
```

如果你是通过代理客户端 UI 开启的 system proxy，也可以在 UI 中关闭。
