# Claude System Proxy

Claude Desktop 可以使用和 Codex 相同的 macOS 系统代理路径。

## 准备

先确认：

- 代理客户端运行中。
- 代理客户端处于规则模式。
- TUN 关闭。
- macOS 系统代理开启。
- Claude / Anthropic 规则已经加入覆写文件。

## 填写 `.env`

```zsh
cp .env.example .env
```

填写真实值：

```zsh
NETWORK_SERVICE="你的网络服务名"
PROXY_HOST="你的本地代理 host"
PROXY_PORT="你的本地 HTTP/HTTPS 代理端口"
CLAUDE_APP_NAME="Claude 的 App 名称"
```

`CLAUDE_APP_NAME` 通常是 `Claude`，但不要假设。以你机器上的 App 名称为准。

## 添加 Claude 规则

使用：

```text
examples/anthropic-rules-prepend.yaml
```

或：

```text
examples/anthropic-rules-list.yaml
```

把 `YOUR_PROXY_GROUP_NAME` 替换成真实代理组名。

## 打开 Claude

```zsh
scripts/open-claude.sh
```

脚本会用 Claude 相关测试 URL 先检查系统代理：

```text
https://claude.ai/
https://claude.com/
https://www.anthropic.com/
```

如果你已经手动确认代理，临时跳过检查：

```zsh
SKIP_PROXY_CHECK=1 scripts/open-claude.sh
```

## 观察连接

在代理客户端连接视图里查找：

```text
claude.ai
claude.com
anthropic.com
claudeusercontent.com
clau.de
```

如果域名出现但走直连，检查规则顺序和代理组名。
