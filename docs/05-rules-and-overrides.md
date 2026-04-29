# 规则与覆写文件

AI App 能打开，不代表规则正确。真正要验证的是相关域名是否命中了你选择的代理组。

## 规则应该放在哪里

优先放在代理客户端提供的覆写层：

```text
subscription profile
  + user override / enhancement / mixin
  -> generated runtime config
  -> proxy core
```

你应该编辑中间的用户覆写层，而不是订阅文件或生成文件。

## 备份

编辑任何已有文件前，先备份：

```zsh
cp "$RULES_TARGET_FILE" "$RULES_TARGET_FILE.bak-$(date +%Y%m%d%H%M%S)"
```

如果你不知道 `RULES_TARGET_FILE` 是哪个文件，先不要改。

## Codex / OpenAI 规则

使用：

```text
examples/openai-rules-prepend.yaml
```

或者当客户端只接受普通列表时使用：

```text
examples/openai-rules-list.yaml
```

重要域名包括：

```text
openai.com
chatgpt.com
oaistatic.com
oaiusercontent.com
statsig.com
featuregates.org
```

## Claude / Anthropic 规则

使用：

```text
examples/anthropic-rules-prepend.yaml
```

或者：

```text
examples/anthropic-rules-list.yaml
```

重要域名包括：

```text
claude.ai
claude.com
anthropic.com
claudeusercontent.com
clau.de
```

## 规则顺序

AI 服务规则应该出现在宽泛规则之前，例如：

```text
DIRECT
GEOIP
MATCH
FINAL
```

如果 AI 域名先被 `DIRECT` 或其他规则吃掉，后面的代理组规则不会生效。

## 修改后要重新加载

修改规则后，需要让代理客户端重新加载配置。优先使用客户端 UI 的 reload / apply / update profile 功能。

只有在你已经确认某个客户端的命令行 reload 行为时，才用命令自动重载。
