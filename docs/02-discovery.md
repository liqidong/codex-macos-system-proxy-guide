# 发现本机配置值

不要凭感觉填写配置。先发现，再修改。

## 必须确认的值

```text
PROXY_HOST              本地系统代理 host
PROXY_PORT              本地 HTTP/HTTPS 代理端口
NETWORK_SERVICE         macOS 网络服务名
YOUR_PROXY_GROUP_NAME   真实代理组名
RULES_TARGET_FILE       规则覆写 / 增强文件
APP_NAME                Codex App 名称
CLAUDE_APP_NAME         Claude App 名称
```

这些值都来自你的机器和你的代理配置，不能从教程里抄。

## 运行 preflight

```zsh
scripts/preflight.sh
```

重点看这些区块：

- `Proxy environment`：`.env` 里是否已经有值。
- `Listening local ports`：本机有哪些监听端口。
- `macOS system proxy`：系统代理是否已开启。
- `Candidate proxy config files`：可能的代理配置目录。

如果出现多个疑似本地代理端口，停下来确认，不要随机选。

## 找 macOS 网络服务名

```zsh
networksetup -listallnetworkservices
```

常见值可能是 `Wi-Fi`、`USB 10/100/1000 LAN`、`Thunderbolt Bridge` 等。以命令输出为准。

## 找系统代理当前值

```zsh
scutil --proxy
```

你要关注：

```text
HTTPEnable
HTTPProxy
HTTPPort
HTTPSEnable
HTTPSProxy
HTTPSPort
```

如果系统代理已经由客户端 UI 开启，这里通常能直接看到 host 和 port。

如果你原本启用了 SOCKS 系统代理，也要记录：

```text
SOCKSEnable
SOCKSProxy
SOCKSPort
```

本仓库脚本默认不会关闭已有 SOCKS 设置，除非你显式设置 `DISABLE_SOCKS_PROXY=1`。

## 找代理组名

代理组名来自你的代理配置文件，通常出现在 `proxy-groups` 或类似字段里。它可能叫 `Proxy`、`🚀 节点选择`、`AI`、`国外流量`，也可能是你自己命名的值。

只使用配置里真实存在的组名。规则里的目标组名如果不存在，客户端可能报错，也可能静默失效。

## 找规则目标文件

优先找这些“不会被订阅更新覆盖”的位置：

- rule provider override
- profile enhancement
- mixin
- merge file
- parser output 前的用户覆写文件
- 客户端提供的 rules prepend / append 配置

不要把远程订阅文件本体当作编辑目标。不要把运行时生成文件当作永久编辑目标。
