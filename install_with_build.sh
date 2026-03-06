#!/bin/bash

# TextPolish 一键安装脚本 (完整版)
# 包含代码克隆、构建、安装

echo "🚀 开始安装 TextPolish..."

# 1. 检查并安装必要的工具
if ! command -v xcodegen &> /dev/null; then
    echo "📦 正在安装 XcodeGen..."
    brew install xcodegen
fi

# 2. 克隆代码（如果不在项目目录）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$SCRIPT_DIR/.git" ]; then
    echo "📥 正在克隆代码仓库..."
    cd /tmp
    rm -rf test-polish-ai
    git clone https://github.com/shaoxia20240902/test-polish-ai.git
    cd test-polish-ai
else
    cd "$SCRIPT_DIR"
fi

# 3. 生成项目
echo "⚙️  正在生成 Xcode 项目..."
xcodegen generate

# 4. 构建
echo "🔨 正在编译（首次可能需要几分钟）..."
xcodebuild -project TextPolish.xcodeproj -scheme TextPolish -configuration Release build 2>&1 | tail -20

# 5. 安装到 Applications
echo "📂 正在安装到 Applications..."
APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/TextPolish-*/Build/Release/TextPolish.app"
APP_PATH=$(ls -d $APP_PATH 2>/dev/null | head -1)

if [ -d "$APP_PATH" ]; then
    cp -R "$APP_PATH" /Applications/
    echo "✅ 安装完成！"
    echo ""
    echo "使用说明："
    echo "1. 打开 Applications 文件夹，双击运行 TextPolish"
    echo "2. 首次运行需要在 '系统设置 > 隐私与安全性 > 辅助功能' 中授权"
    echo "3. 在任意应用中选中文字，按 ⌘⇧F1-F5 触发润色"
    echo "4. 点击菜单栏图标可设置 API"
else
    echo "❌ 构建失败，请检查错误信息"
fi
