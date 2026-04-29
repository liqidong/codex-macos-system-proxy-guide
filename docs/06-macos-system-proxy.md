# macOS System Proxy

macOS system proxy 是网络服务级设置。它比 TUN 轻，但仍然会影响所有尊重系统代理的 App。

## 优先使用客户端 UI

如果代理客户端提供 system proxy 开关，优先在 UI 里打开。这样最容易和客户端当前监听端口保持一致。

打开后检查：

```zsh
scutil --proxy
```

你要看到：

```text
HTTPEnable : 1
HTTPSEnable : 1
```

并记录真实的 host / port。

## 用脚本设置

只有当你明确希望本仓库修改 macOS 网络设置时，才运行：

```zsh
scripts/set-system-proxy.sh
```

运行前必须填写：

```text
NETWORK_SERVICE
PROXY_HOST
PROXY_PORT
```

脚本会设置 HTTP 和 HTTPS system proxy。

## SOCKS 行为

脚本默认不改变已有 SOCKS system proxy 状态。

明确要启用 SOCKS：

```zsh
ENABLE_SOCKS_PROXY=1 scripts/set-system-proxy.sh
```

明确要关闭 SOCKS：

```zsh
DISABLE_SOCKS_PROXY=1 scripts/set-system-proxy.sh
```

不要在不知道原先系统状态的情况下随手改 SOCKS。

## 回滚

把 `NETWORK_SERVICE` 换成真实网络服务名：

```zsh
networksetup -setwebproxystate "$NETWORK_SERVICE" off
networksetup -setsecurewebproxystate "$NETWORK_SERVICE" off
networksetup -setsocksfirewallproxystate "$NETWORK_SERVICE" off
```
