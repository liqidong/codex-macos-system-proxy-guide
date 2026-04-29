# Clash Verge 实战

这一页用 Clash Verge 作为例子讲操作思路，但仓库方法不绑定 Clash Verge。其他兼容 Clash / Mihomo 配置的客户端，也可以用同一套原则迁移。

## 目标状态

```text
Mode: Rule
System Proxy: On
TUN: Off
Rules: AI domains -> real proxy group
```

## 第一步：确认模式

在客户端里确认当前是规则模式。不同版本 UI 名称可能不同，常见叫法包括：

```text
Rule
Rules
Rule Mode
规则
规则模式
```

不要用全局模式来掩盖规则错误。全局模式能让流量通，但它没有验证你的 AI 域名规则是否正确。

## 第二步：关闭 TUN

关闭这些能力：

```text
TUN
Service Mode TUN
Virtual Network Adapter
Enhanced DNS for TUN
DNS Hijack
Transparent Proxy
```

名字随版本变化，按含义判断。目标是不要让整个系统通过虚拟网卡进入代理核心。

## 第三步：开启系统代理

优先使用客户端 UI 的 System Proxy 开关。

开启后运行：

```zsh
scutil --proxy
```

确认 HTTP / HTTPS 代理已启用，并记录 host / port。

## 第四步：找到覆写位置

Clash Verge 类客户端常见有这些位置：

```text
Profiles
Profile enhancement
Merge
Mixin
Parser
Rules prepend
```

不同版本和分支差异很大。原则只有一个：改用户自己的覆写层，不直接改订阅源，不把运行时生成配置当永久方案。

## 第五步：写规则

把示例里的 `YOUR_PROXY_GROUP_NAME` 换成真实代理组名：

```text
examples/openai-rules-prepend.yaml
examples/anthropic-rules-prepend.yaml
```

如果客户端 UI 提供的是纯 rules 列表，使用：

```text
examples/openai-rules-list.yaml
examples/anthropic-rules-list.yaml
```

## 第六步：验证命中

重新加载配置后，打开客户端的连接视图或日志。

打开 Codex 或 Claude，然后观察这些域名是否命中目标代理组：

```text
chatgpt.com
openai.com
oaistatic.com
oaiusercontent.com
claude.ai
anthropic.com
claudeusercontent.com
```

如果域名出现但走了 `DIRECT`，通常是规则顺序不对，或者代理组名写错。
