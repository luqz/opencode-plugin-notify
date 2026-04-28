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
  INSTALL_DIR="$HOME/.config/opencode"
  PLUGIN_DIR="$INSTALL_DIR/plugins"
  echo "🌐 正在全局安装 opencode-plugin-notify..."

  # 创建目录
  echo "📁 创建目录: $PLUGIN_DIR"
  mkdir -p "$PLUGIN_DIR"

  # 复制或下载文件
  echo "📋 复制文件..."
  if [ -f "plugins/notify.js" ]; then
    cp "plugins/notify.js" "$PLUGIN_DIR/notify.js"
    if [ -f "$INSTALL_DIR/notify-config.json" ]; then
      BACKUP="$INSTALL_DIR/notify-config.json.bak.$(date +%s)"
      cp "$INSTALL_DIR/notify-config.json" "$BACKUP"
      echo "💾 已备份旧配置: $BACKUP"
    fi
    cp "notify-config.example.json" "$INSTALL_DIR/notify-config.json"
  else
    echo "⬇️  下载最新代码..."
    curl -fsSL "${RAW_URL}/plugins/notify.js" -o "$PLUGIN_DIR/notify.js"

    if [ -f "$INSTALL_DIR/notify-config.json" ]; then
      BACKUP="$INSTALL_DIR/notify-config.json.bak.$(date +%s)"
      cp "$INSTALL_DIR/notify-config.json" "$BACKUP"
      echo "💾 已备份旧配置: $BACKUP"
    fi
    curl -fsSL "${RAW_URL}/notify-config.example.json" -o "$INSTALL_DIR/notify-config.json"
  fi

  # 输出结果
  echo ""
  echo "✅ 安装完成！"
  echo ""
  echo "📍 安装文件:"
  echo "   $PLUGIN_DIR/notify.js"
  echo "   $INSTALL_DIR/notify-config.json"
  echo ""
  echo "📝 下一步操作："
  echo ""
  echo "1. 编辑配置文件，填入你的机器人信息："
  echo "   $INSTALL_DIR/notify-config.json"
  echo ""
  echo "   或者通过环境变量配置（优先级高于配置文件）："
  echo "   export DINGTALK_TOKEN=xxx DINGTALK_SECRET=xxx"
  echo "   export FEISHU_TOKEN=xxx FEISHU_SECRET=xxx"
  echo ""
  echo "2. 在 opencode.config.js 中引入插件："
  echo "   import { NotifyPlugin } from '~/.config/opencode/plugins/notify.js';"
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
