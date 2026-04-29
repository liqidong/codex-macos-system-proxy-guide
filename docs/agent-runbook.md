# Agent 执行手册

这是给 AI agent 接手本仓库时使用的操作手册。先遵守 [AGENTS.md](../AGENTS.md)，再按本页执行。

## 目标状态

```text
macOS system proxy: enabled
proxy client mode: rule
TUN: disabled
rules: AI service domains -> real proxy group
apps: opened normally through macOS system proxy
```

不要把 per-app 代理注入、TUN、DNS hijack 当成默认方案。

## 1. 只读检查

运行：

```zsh
scripts/preflight.sh
```

读取输出，识别：

```text
PROXY_HOST
PROXY_PORT
NETWORK_SERVICE
YOUR_PROXY_GROUP_NAME
RULES_TARGET_FILE
APP_NAME
CLAUDE_APP_NAME
```

如果缺任何一个配置所必需的值，停止并问用户。不要猜。

## 2. 判断是否可以修改

只有这些位置适合修改：

```text
.env
RULES_TARGET_FILE, after backup
user-created Shortcut / Automator wrapper
```

不要修改：

```text
remote subscription profile
generated runtime config as permanent config
system network proxy settings, unless user explicitly agrees
```

## 3. 确认代理客户端状态

需要用户或可验证证据确认：

- 客户端处于规则模式。
- TUN 关闭。
- DNS hijack / virtual network adapter 没有作为本流程依赖。
- 有用户可编辑的规则覆写、增强、mixin 或 merge 文件。

如果只有订阅文件可改，停止并问用户。

## 4. 填写 `.env`

如果需要仓库脚本设置或检查系统代理：

```zsh
cp .env.example .env
```

填写真实值。不要提交 `.env`。

## 5. 备份并添加规则

编辑规则目标文件前：

```zsh
cp "$RULES_TARGET_FILE" "$RULES_TARGET_FILE.bak-$(date +%Y%m%d%H%M%S)"
```

Codex / OpenAI 规则：

```text
examples/openai-rules-prepend.yaml
```

Claude / Anthropic 规则：

```text
examples/anthropic-rules-prepend.yaml
```

把 `YOUR_PROXY_GROUP_NAME` 替换为真实代理组名。规则应该出现在宽泛的 `DIRECT` / `GEOIP` / `MATCH` 之前。

## 6. 重新加载客户端配置

优先让用户通过代理客户端 UI reload / apply。

只有已经确认客户端命令和当前客户端匹配时，才能使用命令行 reload。

## 7. 启用 macOS 系统代理

优先让用户在代理客户端 UI 里启用 system proxy。

如果用户明确同意由仓库脚本修改系统网络代理，并且 `.env` 已填写：

```zsh
scripts/set-system-proxy.sh
```

这会影响所有尊重 macOS 系统代理的 App。

脚本默认不关闭已有 SOCKS 系统代理。只有用户明确要求时，才设置 `DISABLE_SOCKS_PROXY=1`。

## 8. 验证

```zsh
scripts/check-system-proxy.sh
```

如果要打开 Codex：

```zsh
scripts/open-codex.sh
```

如果要打开 Claude：

```zsh
scripts/open-claude.sh
```

最后在代理客户端连接视图里确认相关域名命中目标代理组。

## 停止条件

遇到这些情况，停止并问用户：

- 多个可能的本地代理端口。
- 代理组名不明确。
- 找不到非订阅的规则覆写位置。
- 只能编辑远程订阅文件。
- 客户端必须开启 TUN 才能工作。
- 启用系统代理会影响其他 App，但用户尚未同意。
