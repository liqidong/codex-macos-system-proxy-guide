# 排障

## Codex 打开后还是连不上

先确认本地代理入口能用：

```zsh
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" scripts/check-proxy.sh
```

如果这里失败，问题在本地代理入口，不在 Codex。

## 代理客户端里看不到 Codex 连接

确认你不是从 Dock 或 Finder 启动的原始 Codex App。

你应该通过下面任一方式启动：

```text
scripts/launch-codex-with-proxy.sh
macOS 快捷指令
Automator App
```

## 规则没有命中代理组

检查三件事：

```text
1. YOUR_PROXY_GROUP_NAME 是否是真实存在的代理组
2. 规则是否放在 GEOIP / MATCH / DIRECT 之前
3. 修改后是否重载了配置
```

## auth.openai.com 没有单独规则可以吗？

如果已经有：

```yaml
- DOMAIN-SUFFIX,openai.com,YOUR_PROXY_GROUP_NAME
```

它会覆盖 `auth.openai.com`。

但为了让读配置的人一眼看懂，也可以保留单独的：

```yaml
- DOMAIN-SUFFIX,auth.openai.com,YOUR_PROXY_GROUP_NAME
```

## 为什么系统代理关闭也能用？

因为脚本把代理环境变量直接注入给 Codex。

系统代理是 macOS 的全局入口。脚本注入是只针对这个 App 的入口。

## 为什么系统代理开启后所有应用都走代理？

这是系统代理的设计。

如果你只想让 Codex 走代理，不要开系统代理，直接用脚本启动 Codex。

## 如何确认 Codex 进程拿到了代理变量？

macOS 不总是方便直接查看 GUI 进程的环境变量。更可靠的办法是看代理客户端连接页。

你应该能看到这些域名之一：

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
statsig.com
featuregates.org
```

