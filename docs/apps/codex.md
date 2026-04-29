# Codex System Proxy

Codex 走 macOS 系统代理时，不需要给 App 注入单独的代理环境变量。关键是先让系统代理链路正确，再启动 Codex。

## 准备

先确认：

- 代理客户端运行中。
- 代理客户端处于规则模式。
- TUN 关闭。
- macOS 系统代理开启。
- OpenAI / ChatGPT 规则已经加入覆写文件。

## 填写 `.env`

```zsh
cp .env.example .env
```

填写真实值：

```zsh
NETWORK_SERVICE="你的网络服务名"
PROXY_HOST="你的本地代理 host"
PROXY_PORT="你的本地 HTTP/HTTPS 代理端口"
APP_NAME="Codex 的 App 名称"
```

`APP_NAME` 通常是 `Codex`，但如果你的应用名不同，以 `/Applications` 或 `~/Applications` 里的名字为准。

## 验证系统代理

```zsh
scripts/check-system-proxy.sh
```

这个脚本会读取 macOS 当前系统代理，并用 `curl --proxy` 测试 URL。

## 打开 Codex

```zsh
scripts/open-codex.sh
```

脚本会先运行系统代理检查，再通过 `open -a "$APP_NAME"` 打开 Codex。

如果你已经手动确认代理，临时跳过检查：

```zsh
SKIP_PROXY_CHECK=1 scripts/open-codex.sh
```

## 观察连接

在代理客户端连接视图里查找：

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
statsig.com
featuregates.org
```

看到域名不够，还要确认它们命中目标代理组。
