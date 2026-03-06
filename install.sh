#!/bin/bash

# TextPolish 一键安装脚本
# 使用方法: curl -fsSL https://raw.githubusercontent.com/shaoxia20240902/test-polish-ai/main/install.sh | bash

set -e

echo "📦 正在下载 TextPolish..."

# 获取最新 Release
LATEST_TAG=$(curl -sL https://api.github.com/repos/shaoxia20240902/test-polish-ai/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
DOWNLOAD_URL="https://github.com/shaoxia20240902/test-polish-ai/releases/download/${LATEST_TAG}/TextPolish.app.zip"

# 下载
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL -o app.zip "$DOWNLOAD_URL"

echo "📂 正在安装到 Applications..."
unzip -o app.zip
mv TextPolish.app /Applications/

# 清理
cd /
rm -rf "$TMP_DIR"

echo "✅ 安装完成！"
echo ""
echo "使用说明："
echo "1. 首次运行需要在 '系统设置 > 隐私与安全性 > 辅助功能' 中授权"
echo "2. 在任意应用中选中文字，按 ⌘⇧F1-F5 触发润色"
echo "3. 点击菜单栏图标可设置 API"
