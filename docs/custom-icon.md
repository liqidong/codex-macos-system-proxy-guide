# 换图标

macOS 快捷指令可以换颜色和符号，但如果你想用自己的图片，最稳的是做一个 Automator App。这个 App 只检查系统代理并打开 Codex，不做 TUN 或 per-app proxy injection。

## 方案 A：快捷指令自带图标

适合只想快速区分入口的人。

```text
快捷指令 App -> 打开你的快捷指令 -> 点击名称旁边的图标 -> 选择颜色和符号
```

## 方案 B：Automator App 自定义图标

1. 打开 Automator。
2. 新建文稿，类型选择“应用程序”。
3. 搜索并添加“运行 Shell 脚本”。
4. Shell 选择 `/bin/zsh`。
5. 粘贴 `examples/shortcut-shell.zsh` 里的内容。
6. 替换 `REPO_DIR`。
7. 保存为 `Codex System Proxy.app`。

换图标：

```text
Finder -> 选中 Codex System Proxy.app -> Command + I
```

把你的 `.icns` 文件拖到信息窗口左上角的小图标上。

如果你只有 PNG，可以先转换成 ICNS。常见做法是使用在线转换工具，或用 macOS 自带预览导出多尺寸后再生成 `.icns`。

## 图标建议

- 1024 x 1024 的 PNG 或 ICNS 起步。
- 背景留一点边距，不要把主体贴到边缘。
- 图标名建议包含用途，比如 `codex-system-proxy.icns`。
