# Troubleshooting

## Codex still cannot connect

Check system proxy first:

```zsh
scripts/check-system-proxy.sh
```

If this fails, fix system proxy before touching Codex.

## System proxy is disabled

Use your proxy client UI to enable system proxy, or fill `.env` and run:

```zsh
scripts/set-system-proxy.sh
```

Then verify:

```zsh
scutil --proxy
```

You want HTTP and HTTPS enabled.

## TUN is still enabled

Turn it off in the proxy client.

Look for settings named:

```text
TUN
Enhanced mode
Virtual adapter
Transparent proxy
DNS hijack
Redirect all traffic
```

This guide is designed to avoid TUN because TUN can make the whole system feel slow or unstable on some Macs.

## Rules do not hit the proxy group

Check:

```text
1. YOUR_PROXY_GROUP_NAME is a real group in the config.
2. Rules appear before DIRECT / GEOIP / MATCH.
3. The proxy client is in rule mode.
4. The config was reloaded after editing.
```

## auth.openai.com has no separate rule

If this exists:

```yaml
- DOMAIN-SUFFIX,openai.com,YOUR_PROXY_GROUP_NAME
```

it already covers `auth.openai.com`.

Keeping the explicit rule is still fine:

```yaml
- DOMAIN-SUFFIX,auth.openai.com,YOUR_PROXY_GROUP_NAME
```

It makes the config easier to audit.

## Codex opens, but no traffic appears in the proxy client

Check that Codex was opened after system proxy was enabled.

Then run:

```zsh
scripts/open-codex.sh
```

If no traffic appears, the app may be using an existing session. Quit Codex fully, then open it again.

## System proxy affects other apps

That is expected.

System proxy is a macOS-level setting. Apps that respect system proxy may enter the proxy client.

This is still lighter than TUN because it does not install a virtual network path for all traffic.

## How to roll back

Turn off system proxy in the proxy client UI, or run:

```zsh
networksetup -setwebproxystate "Wi-Fi" off
networksetup -setsecurewebproxystate "Wi-Fi" off
networksetup -setsocksfirewallproxystate "Wi-Fi" off
```

Replace `Wi-Fi` with your actual network service.

