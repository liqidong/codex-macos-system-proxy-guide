# 安全工作流

这页把仓库的安全原则整理成人类可执行流程。

## 先确认，再修改

修改前必须知道：

```text
PROXY_HOST
PROXY_PORT
NETWORK_SERVICE
YOUR_PROXY_GROUP_NAME
RULES_TARGET_FILE
APP_NAME or CLAUDE_APP_NAME
```

缺值就停。不要用常见端口、常见组名或别人截图里的值。

## 能改什么

可以改：

```text
.env
用户自己的规则覆写 / 增强 / mixin / merge 文件
用户自己创建的 Shortcut / Automator 包装
```

不要改：

```text
远程订阅文件
生成出来的运行时配置
系统网络代理设置，除非用户明确同意
```

## 备份

编辑已有代理配置前：

```zsh
cp "$RULES_TARGET_FILE" "$RULES_TARGET_FILE.bak-$(date +%Y%m%d%H%M%S)"
```

如果你还不知道 `RULES_TARGET_FILE`，说明还没到编辑步骤。

## 不用全局模式掩盖问题

Global 模式可以快速确认节点能用，但不能证明规则正确。最终状态应该回到 Rule 模式。

## 不用 TUN 掩盖问题

如果 system proxy 路径能工作，不要为了“看起来通了”打开 TUN、DNS hijack 或虚拟网卡。
