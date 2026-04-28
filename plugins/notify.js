import { readFileSync } from "fs";
import { createHmac } from "crypto";
import { join } from "path";
import { homedir } from "os";

function loadConfig() {
  const configPath = join(homedir(), ".config", "opencode", "notify-config.json");
  try {
    const config = JSON.parse(readFileSync(configPath, "utf-8"));

    if (config.dingtalk) {
      config.dingtalk.token = process.env.DINGTALK_TOKEN || config.dingtalk.token;
      config.dingtalk.secret = process.env.DINGTALK_SECRET || config.dingtalk.secret;
    }
    if (config.feishu) {
      config.feishu.token = process.env.FEISHU_TOKEN || config.feishu.token;
      config.feishu.secret = process.env.FEISHU_SECRET || config.feishu.secret;
    }

    return {
      ...config,
      events: {
        "permission.asked": true,
        "session.idle": true,
        "session.error": true,
        ...config.events
      }
    };
  } catch (e) {
    console.error("[notify] 无法加载配置文件:", configPath);
    return null;
  }
}

function signDingTalk(secret) {
  const timestamp = Date.now();
  const stringToSign = `${timestamp}\n${secret}`;
  const hmac = createHmac("sha256", secret);
  hmac.update(stringToSign);
  const sign = encodeURIComponent(hmac.digest("base64"));
  return { timestamp, sign };
}

function signFeishu(secret) {
  const timestamp = Math.floor(Date.now() / 1000);
  const stringToSign = `${timestamp}\n${secret}`;
  const hmac = createHmac("sha256", stringToSign);
  const sign = hmac.digest("base64");
  return { timestamp, sign };
}

async function sendDingTalk(config, message) {
  if (!config.enabled || !config.token) {
    return;
  }

  let url = `https://oapi.dingtalk.com/robot/send?access_token=${config.token}`;
  if (config.useSign && config.secret) {
    const { timestamp, sign } = signDingTalk(config.secret);
    url += `&timestamp=${timestamp}&sign=${sign}`;
  }

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        msgtype: "markdown",
        markdown: {
          title: "OpenCode 通知",
          text: message
        }
      })
    });
    const data = await res.json();
    if (data.errcode !== 0) {
      console.error("[notify] 钉钉发送失败:", data.errmsg);
    }
  } catch (e) {
    console.error("[notify] 钉钉请求失败:", e.message);
  }
}

async function sendFeishu(config, message) {
  if (!config.enabled || !config.token) {
    return;
  }

  const payload = {
    msg_type: "interactive",
    card: {
      header: {
        title: { tag: "plain_text", content: "OpenCode 通知" },
        template: "blue"
      },
      elements: [
        { tag: "div", text: { tag: "lark_md", content: message } }
      ]
    }
  };

  if (config.useSign && config.secret) {
    const { timestamp, sign } = signFeishu(config.secret);
    payload.timestamp = timestamp;
    payload.sign = sign;
  }

  try {
    const url = `https://open.feishu.cn/open-apis/bot/v2/hook/${config.token}`;
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if (data.code !== 0) {
      console.error("[notify] 飞书发送失败:", data.msg);
    }
  } catch (e) {
    console.error("[notify] 飞书请求失败:", e.message);
  }
}

async function sendNotification(config, message) {
  if (!config) return;

  const promises = [];
  if (config.dingtalk?.enabled) {
    promises.push(sendDingTalk(config.dingtalk, message));
  }
  if (config.feishu?.enabled) {
    promises.push(sendFeishu(config.feishu, message));
  }
  await Promise.all(promises);
}

export const NotifyPlugin = async ({ project, directory }) => {
  const config = loadConfig();
  if (!config) {
    console.error("[notify] 配置加载失败，插件未激活");
    return {};
  }

  return {
    event: async ({ event }) => {
      if (!config.events?.[event.type]) return;

      if (event.type === "permission.asked") {
        try {
          const keyword = config.feishu?.keyword ? `[${config.feishu.keyword}] ` : "";
          const msg = `${keyword}## ⚠️ 需要权限确认

**项目：** ${project?.name || directory}
**工具：** \`${event?.tool || "unknown"}\`
**操作：** ${event?.description || "需要你的确认"}

请打开 OpenCode 查看详情并处理。`;

          await sendNotification(config, msg);
        } catch (e) {
          console.error("[notify] 权限通知发送失败:", e.message);
        }
      }

      if (event.type === "session.idle") {
        try {
          const keyword = config.feishu?.keyword ? `[${config.feishu.keyword}] ` : "";
          const msg = `${keyword}## ✅ 任务完成

**项目：** ${project?.name || directory}

OpenCode 已完成当前任务，会话已空闲。`;

          await sendNotification(config, msg);
        } catch (e) {
          console.error("[notify] 空闲通知发送失败:", e.message);
        }
      }

      if (event.type === "session.error") {
        try {
          const keyword = config.feishu?.keyword ? `[${config.feishu.keyword}] ` : "";
          const msg = `${keyword}## ❌ 发生错误

**项目：** ${project?.name || directory}
**错误：** ${event?.error?.message || "未知错误"}

请检查 OpenCode 会话详情。`;

          await sendNotification(config, msg);
        } catch (e) {
          console.error("[notify] 错误通知发送失败:", e.message);
        }
      }
    }
  };
};
