# Codex Proxy Launcher Guide

让 Codex 单独走本地代理，同时保留系统其它应用的原始网络行为。

平台边界：当前流程面向 macOS。

这个仓库不是某个具体代理客户端的教程。它讲的是通用流程：

- 在 Clash-compatible 规则里补齐 OpenAI / ChatGPT / Codex 相关域名。
- 不直接修改订阅文件，避免订阅更新后规则丢失。
- 通过启动脚本给 Codex 注入代理环境变量。
- 用 macOS 快捷指令或 Automator 做一个一键启动入口。
- 给启动入口换图标。

如果你是 AI agent，先读：

[AGENTS.md](AGENTS.md)

然后按这个执行手册走：

[docs/agent-runbook.md](docs/agent-runbook.md)

你需要自己替换这些变量：

```text
YOUR_PROXY_GROUP_NAME     你的代理组名称
HTTP_PROXY_URL            你的本地 HTTP 代理地址
HTTPS_PROXY_URL           你的本地 HTTPS 代理地址，通常可和 HTTP_PROXY_URL 一样
ALL_PROXY_URL             可选，SOCKS 代理地址
APP_EXECUTABLE            Codex App 可执行文件路径
```

本仓库不会写死任何代理软件名称、订阅地址、节点名或端口。

## 适用场景

你想要的是这种效果：

```text
Codex App
  -> 本地代理入口
  -> 规则判断
  -> OpenAI / ChatGPT / GitHub 等域名走指定代理组
  -> 其它域名按你的规则直连或代理
```

而不是这种效果：

```text
整个系统所有 App 都被强制走代理
```

这对调试很有用。Codex 走代理，系统其它应用可以不受影响。

## 总流程

1. 找到你的本地代理入口。
2. 找到你的代理组名称。
3. 在规则增强或覆写文件里添加域名规则。
4. 重载代理配置。
5. 用脚本启动 Codex，并把代理环境变量注入给 Codex。
6. 把脚本做成 macOS 快捷指令或 Automator App。
7. 测试连接和规则命中。

给 AI agent 的最短路径：

```zsh
scripts/preflight.sh
cp .env.example .env
# edit .env
scripts/check-proxy.sh
scripts/launch-codex-with-proxy.sh
```

## 1. 找到本地代理入口

在你的代理客户端里找到本地监听地址。

常见形式是：

```text
http://127.0.0.1:YOUR_LOCAL_HTTP_PORT
socks5://127.0.0.1:YOUR_LOCAL_SOCKS_PORT
```

不要照抄别人的端口。每个人的客户端和配置都可能不同。

你最终需要填入：

```zsh
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
ALL_PROXY_URL="socks5://127.0.0.1:YOUR_LOCAL_SOCKS_PORT"
```

如果你只有 HTTP 混合端口，可以不设置 `ALL_PROXY_URL`。

也可以先运行预检脚本，让它列出本机候选端口和 Codex 路径：

```zsh
scripts/preflight.sh
```

如果预检输出多个可能端口，不要猜。去你的代理客户端设置页确认，或者问使用者。

## 2. 添加 Clash-compatible 规则

不要直接改订阅文件。

原因很简单：订阅一更新，你手动写进去的规则就可能被覆盖。正确做法是把规则写到客户端支持的规则增强、Mixin、Merge、Override、Profile Enhancement 之类的位置。

规则示例见：

[examples/clash-compatible-rules.yaml](examples/clash-compatible-rules.yaml)

如果你的客户端只接受纯 `rules:` 列表，看：

[examples/rules-list-only.yaml](examples/rules-list-only.yaml)

核心规则：

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

最关键的是：

```yaml
- DOMAIN-SUFFIX,chatgpt.com,YOUR_PROXY_GROUP_NAME
```

`YOUR_PROXY_GROUP_NAME` 必须替换成你配置里真实存在的代理组名。常见名字可能是 `PROXY`、`Proxy`、`节点选择`，也可能是你自己的自定义名称。

规则顺序很重要。应该放在 `GEOIP`、`MATCH`、默认直连规则之前。

安全编辑流程：

```zsh
cp "$RULES_TARGET_FILE" "$RULES_TARGET_FILE.bak-$(date +%Y%m%d%H%M%S)"
```

然后再修改规则文件。不要直接覆盖订阅文件或生成后的运行配置。

## 3. 启动 Codex 时注入代理

macOS 从 Finder、Dock、Launchpad 启动 App 时，通常不会继承你终端里的 `HTTP_PROXY` 环境变量。

所以更稳的方式是直接启动 App 的可执行文件，并在启动时注入代理变量。

主脚本见：

[scripts/launch-codex-with-proxy.sh](scripts/launch-codex-with-proxy.sh)

推荐先建 `.env`：

```zsh
cp .env.example .env
```

再把 `.env` 里的值改成你自己的。脚本会自动读取 `.env`。

最小用法：

```zsh
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
scripts/launch-codex-with-proxy.sh
```

如果你也想提供 SOCKS 代理：

```zsh
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
ALL_PROXY_URL="socks5://127.0.0.1:YOUR_LOCAL_SOCKS_PORT" \
scripts/launch-codex-with-proxy.sh
```

如果你的 Codex 安装路径不同：

```zsh
APP_EXECUTABLE="/path/to/Codex.app/Contents/MacOS/Codex" \
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
scripts/launch-codex-with-proxy.sh
```

默认情况下，脚本不会退出已打开的 Codex。这样不会打断当前会话。

如果你要干净重启：

```zsh
QUIT_EXISTING=1 scripts/launch-codex-with-proxy.sh
```

脚本默认会同时传入 Electron / Chromium 的 `--proxy-server` 参数。环境变量是第一层，`--proxy-server` 是第二层，实际更稳。

如果你只想用环境变量：

```zsh
USE_ELECTRON_PROXY_ARGS=0 scripts/launch-codex-with-proxy.sh
```

## 4. 生成 macOS 快捷指令

打开 macOS 自带的“快捷指令”App：

```text
新建快捷指令 -> 添加操作 -> 运行 Shell 脚本
```

Shell 选择：

```text
/bin/zsh
```

脚本案例见：

[examples/shortcut-shell.zsh](examples/shortcut-shell.zsh)

把里面的 `REPO_DIR` 和代理变量改成你自己的：

```zsh
REPO_DIR="$HOME/Desktop/codex-proxy-launcher-guide"
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT"
ALL_PROXY_URL=""
```

然后把快捷指令命名为：

```text
Codex via Proxy
```

你可以把它固定到菜单栏，也可以添加到 Dock。

## 5. 换图标

快捷指令自带图标够用，但如果你想用自定义图标，建议做成 Automator App。

完整流程见：

[docs/custom-icon.md](docs/custom-icon.md)

最稳的方式：

```text
Automator -> 新建应用程序 -> 运行 Shell 脚本 -> 保存为 Codex via Proxy.app
```

然后在 Finder 里对这个 App 换图标。

## 6. 验证是否生效

先检查本地代理是否能连：

```zsh
scripts/check-proxy.sh
```

再启动 Codex：

```zsh
scripts/launch-codex-with-proxy.sh
```

然后打开你的代理客户端连接面板，观察是否出现这些域名：

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
statsig.com
featuregates.org
```

并确认它们命中你指定的代理组。

## 7. 案例

### 案例 A：只让 Codex 走代理

适合你不想改系统代理，只想让 Codex 可用。

```zsh
HTTP_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
HTTPS_PROXY_URL="http://127.0.0.1:YOUR_LOCAL_HTTP_PORT" \
scripts/launch-codex-with-proxy.sh
```

### 案例 B：系统代理关闭，规则仍然生效

只要 Codex 是通过脚本启动的，它会自己把流量发给本地代理入口。代理客户端再根据规则决定哪些域名走代理组。

```text
系统代理：关闭
代理客户端：运行中
Codex：用本仓库脚本启动
```

### 案例 C：系统代理开启，但仍保留 Codex 快捷入口

这种情况下，系统里遵守系统代理的 App 都会进入代理客户端。Codex 快捷入口仍然可用，只是它不再是唯一入口。

```text
系统代理：开启
代理客户端模式：规则模式
Codex：可用 Finder 启动，也可用快捷入口启动
```

## 8. 常见问题

### 为什么不直接写死端口？

因为端口是本机配置，不是通用知识。别人照抄端口，经常会复制出一个不能用的配置。

### 为什么不直接写代理软件名字？

因为这个流程适用于很多本地代理客户端。关键不是软件名字，而是三件事：

```text
本地代理入口
规则增强位置
真实代理组名称
```

### 为什么 Codex 从 Dock 打开不走代理？

Dock 启动的 GUI App 通常拿不到你在终端里设置的环境变量。脚本直接启动可执行文件，可以把代理变量明确交给 Codex。

脚本还会默认传入 `--proxy-server` 参数，减少 Electron App 不吃环境变量时的失败概率。

### 为什么规则要放在前面？

Clash-compatible 规则一般从上往下匹配。放在后面可能先被 `DIRECT`、`GEOIP` 或 `MATCH` 命中。

## 9. 回滚

取消 Codex 单独代理：

```text
以后不要用 Codex via Proxy 快捷指令，直接打开原始 Codex App。
```

取消规则增强：

```yaml
prepend: []

append: []

delete: []
```

或者删除你添加的 OpenAI / ChatGPT 相关规则，然后重载配置。

## 10. 发布到 GitHub

本地仓库已经可以直接发布。

发布前确认：

```zsh
git status --short
git ls-files .env
```

第二条应该没有输出。`.env` 是本机配置，不应该提交。

如果你使用 GitHub CLI：

```zsh
gh repo create codex-proxy-launcher-guide --public --source=. --remote=origin --push
```

如果你想先在 GitHub 网页上创建空仓库：

```zsh
git remote add origin git@github.com:YOUR_NAME/codex-proxy-launcher-guide.git
git branch -M main
git push -u origin main
```

把 `YOUR_NAME` 换成你的 GitHub 用户名或组织名。

## 仓库结构

```text
.
├── .env.example
├── README.md
├── AGENTS.md
├── scripts
│   ├── check-proxy.sh
│   ├── preflight.sh
│   └── launch-codex-with-proxy.sh
├── examples
│   ├── clash-compatible-rules.yaml
│   ├── rules-list-only.yaml
│   └── shortcut-shell.zsh
└── docs
    ├── agent-runbook.md
    ├── custom-icon.md
    └── troubleshooting.md
```
