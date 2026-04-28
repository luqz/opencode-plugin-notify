# opencode-plugin-notify

OpenCode 通知插件，支持钉钉和飞书机器人推送。

## 功能

- **钉钉机器人** - 支持加签安全设置，Markdown 格式消息
- **飞书机器人** - 支持加签安全设置，卡片消息格式
- **事件监听** - 自动监听以下 OpenCode 事件：
  - `permission.asked` - 需要权限确认时通知
  - `session.idle` - 任务完成时通知
  - `session.error` - 发生错误时通知
- **环境变量覆盖** - 敏感信息支持通过环境变量配置

## 安装

### 快速安装（推荐）

```bash
# 安装到当前目录（默认）
curl -fsSL https://raw.githubusercontent.com/luqz/opencode-plugin-notify/main/install.sh | sh

# 全局安装（安装到 ~/.config/opencode/plugins/）
curl -fsSL https://raw.githubusercontent.com/luqz/opencode-plugin-notify/main/install.sh | sh -s -- -g
```

### 手动安装

如果不希望使用脚本，也可以手动下载文件：

**本地安装：**

```bash
mkdir -p .opencode/plugins
curl -fsSL https://raw.githubusercontent.com/luqz/opencode-plugin-notify/main/plugins/notify.js -o .opencode/plugins/notify.js
curl -fsSL https://raw.githubusercontent.com/luqz/opencode-plugin-notify/main/notify-config.example.json -o .opencode/notify-config.json
```

**全局安装：**

```bash
mkdir -p ~/.config/opencode/plugins/opencode-plugin-notify
curl -fsSL https://github.com/luqz/opencode-plugin-notify/archive/refs/heads/main.tar.gz | tar -xz -C ~/.config/opencode/plugins/opencode-plugin-notify --strip-components=1
```

## 配置

### 配置文件

**本地安装：**

安装脚本已自动创建 `./.opencode/notify-config.json`，直接编辑即可：

```bash
# 编辑本地配置文件
./.opencode/notify-config.json
```

**全局安装：**

```bash
mkdir -p ~/.config/opencode
cp ~/.config/opencode/plugins/opencode-plugin-notify/notify-config.example.json ~/.config/opencode/notify-config.json
```

编辑配置文件，填入你的机器人信息：

```json
{
  "dingtalk": {
    "enabled": true,
    "token": "你的钉钉机器人 Token",
    "secret": "你的钉钉加签密钥（可选）",
    "useSign": true
  },
  "feishu": {
    "enabled": true,
    "token": "你的飞书机器人 Token",
    "secret": "你的飞书加签密钥（可选）",
    "useSign": true,
    "keyword": "OpenCode"
  },
  "events": {
    "permission.asked": true,
    "session.idle": true,
    "session.error": true
  }
}
```

## 环境变量（可选）

你也可以通过环境变量覆盖配置文件中的敏感信息：

| 环境变量 | 说明 |
|---------|------|
| `DINGTALK_TOKEN` | 钉钉机器人 Token |
| `DINGTALK_SECRET` | 钉钉加签密钥 |
| `FEISHU_TOKEN` | 飞书机器人 Token |
| `FEISHU_SECRET` | 飞书加签密钥 |

示例：

```bash
export DINGTALK_TOKEN="your_token"
export DINGTALK_SECRET="your_secret"
```

## 使用方法

### 本地安装

OpenCode 会自动加载 `.opencode/plugins/` 目录下的插件，无需手动配置。

安装完成后，直接编辑 `./.opencode/notify-config.json` 即可使用。

### 钉钉机器人设置

1. 在钉钉群中添加自定义机器人
2. 选择「加签」安全设置，复制密钥到 `secret` 字段
3. 复制 Webhook 地址中的 `access_token` 部分到 `token` 字段

### 飞书机器人设置

1. 在飞书群中添加自定义机器人
2. 选择「签名校验」安全设置，复制密钥到 `secret` 字段
3. 复制 Webhook 地址中的 token 部分
4. 如需设置自定义关键词，填写到 `keyword` 字段

## 事件说明

| 事件 | 触发时机 | 说明 |
|------|---------|------|
| `permission.asked` | 工具请求权限时 | 收到需要人工确认的操作时发送通知 |
| `session.idle` | 会话空闲时 | 任务执行完毕，等待新指令时发送通知 |
| `session.error` | 发生错误时 | 执行过程中出现错误时发送通知 |

你可以在配置中按需开启或关闭某个事件的通知：

```json
{
  "events": {
    "permission.asked": true,
    "session.idle": false,
    "session.error": true
  }
}
```

## License

MIT
