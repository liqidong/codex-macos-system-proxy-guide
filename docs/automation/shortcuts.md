# Shortcuts 和 Automator

本仓库提供的打开脚本可以放进 macOS Shortcuts 或 Automator，做成可点击入口。

## Codex

参考：

```text
examples/shortcut-open-codex.zsh
```

它会调用：

```text
scripts/open-codex.sh
```

## Claude

参考：

```text
examples/shortcut-open-claude.zsh
```

它会调用：

```text
scripts/open-claude.sh
```

## 注意

Shortcut 只是启动包装，不负责发现端口、写规则或开启系统代理。

先完成核心配置，再做快捷入口。
