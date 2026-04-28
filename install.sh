#!/bin/sh

set -e

REPO="luqz/opencode-plugin-notify"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# 解析参数
GLOBAL=false
while [ $# -gt 0 ]; do
  case $1 in
    -g|--global)
      GLOBAL=true
      shift
      ;;
    *)
      echo "未知选项: $1"
      echo "用法: $0 [-g|--global]"
      exit 1
      ;;
  esac
done

# 确定安装路径
if [ "$GLOBAL" = true ]; then
  INSTALL_DIR="$HOME/.config/opencode/plugins/opencode-plugin-notify"
  echo "🌐 正在全局安装 opencode-plugin-notify..."

  # 创建目录
  echo "📁 创建目录: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"

  # 下载并解压
  echo "⬇️  下载最新代码..."
  TMP_DIR=$(mktemp -d)
  trap "rm -rf $TMP_DIR" EXIT

  curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TMP_DIR" --strip-components=1

  # 复制文件
  echo "📋 复制文件..."
  cp -r "$TMP_DIR"/* "$INSTALL_DIR/"

  # 输出结果
  echo ""
  echo "✅ 安装完成！"
  echo ""
  echo "📍 安装路径: $INSTALL_DIR"
  echo ""
  echo "📝 下一步操作："
  echo ""
  echo "1. 复制配置文件："
  echo "   mkdir -p ~/.config/opencode"
  echo "   cp ~/.config/opencode/plugins/opencode-plugin-notify/notify-config.example.json ~/.config/opencode/notify-config.json"
  echo ""
  echo "2. 编辑配置文件，填入你的机器人信息"
  echo ""
  echo "3. 在 opencode.config.js 中引入插件："
  echo "   import { NotifyPlugin } from '~/.config/opencode/plugins/opencode-plugin-notify/plugins/notify.js';"
else
  echo "📦 正在本地安装 opencode-plugin-notify..."

  # 创建目录
  mkdir -p "./.opencode/plugins"

  # 复制文件
  echo "📋 复制文件..."
  if [ -f "plugins/notify.js" ]; then
    cp "plugins/notify.js" "./.opencode/plugins/notify.js"
    if [ -f "./.opencode/notify-config.json" ]; then
      BACKUP="./.opencode/notify-config.json.bak.$(date +%s)"
      cp "./.opencode/notify-config.json" "$BACKUP"
      echo "💾 已备份旧配置: $BACKUP"
    fi
    cp "notify-config.example.json" "./.opencode/notify-config.json"
  else
    curl -fsSL "${RAW_URL}/plugins/notify.js" -o "./.opencode/plugins/notify.js"
    if [ -f "./.opencode/notify-config.json" ]; then
      BACKUP="./.opencode/notify-config.json.bak.$(date +%s)"
      cp "./.opencode/notify-config.json" "$BACKUP"
      echo "💾 已备份旧配置: $BACKUP"
    fi
    curl -fsSL "${RAW_URL}/notify-config.example.json" -o "./.opencode/notify-config.json"
  fi

  # 输出结果
  echo ""
  echo "✅ 安装完成！"
  echo ""
  echo "📍 安装文件:"
  echo "   ./.opencode/plugins/notify.js"
  echo "   ./.opencode/notify-config.json"
  echo ""
  echo "📝 下一步操作："
  echo ""
  echo "1. 编辑配置文件，填入你的机器人信息："
  echo "   ./.opencode/notify-config.json"
  echo ""
  echo "   或者通过环境变量配置（优先级高于配置文件）："
  echo "   export DINGTALK_TOKEN=xxx DINGTALK_SECRET=xxx"
  echo "   export FEISHU_TOKEN=xxx FEISHU_SECRET=xxx"
fi

echo ""
echo "📖 详细文档: https://github.com/${REPO}#readme"
