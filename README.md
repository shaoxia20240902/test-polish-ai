# TextPolish - macOS 文本润色插件

<div align="center">

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一个运行在 macOS 菜单栏的文本润色工具，通过大模型 API 优化选中文本。

</div>

## 功能特性

- **5 个可配置快捷键**: ⌘F1 - ⌘F5
- **全局快捷键触发**: 在任意应用中选中文字，按快捷键即可润色
- **大模型润色**: 支持通义千问、Kimi、OpenAI、Claude 等
- **结果预览**: 弹窗显示原文和润色后内容，支持复制或替换
- **双模式**: 一键安装版（预配 API）或源码版（自己配置）

### 默认快捷键

| 快捷键 | 功能 |
|--------|------|
| ⌘F1 | 通用润色 |
| ⌘F2 | 精简总结 |
| ⌘F3 | 正式改写 |
| ⌘F4 | 代码注释 |
| ⌘F5 | 中英翻译 |

---

## 安装方式

### 方式一：一键安装版（推荐）

使用预配置的大模型 API，下载即用：

```bash
# 方式 A: 使用 Homebrew Tap
brew tap shaoxia20240902/text-polish
brew install text-polish

# 方式 B: 直接下载 Release
# 访问 https://github.com/shaoxia20240902/test-polish-ai/releases
```

> ⚠️ 一键安装版使用默认 API 配置，如需使用自己的 API Key，可在菜单栏点击 "设置 API" 覆盖。

### 方式二：源码安装版

自行配置 API Key：

```bash
# 1. 克隆仓库
git clone https://github.com/shaoxia20240902/test-polish-ai.git
cd test-polish-ai

# 2. 安装 XcodeGen（如未安装）
brew install xcodegen

# 3. 生成项目
xcodegen generate

# 4. 安装依赖
swift package resolve

# 5. 构建并运行
open TextPolish.xcodeproj
# 在 Xcode 中按 ⌘R 运行
```

或命令行构建：

```bash
xcodebuild -project TextPolish.xcodeproj -scheme TextPolish -configuration Debug build
```

---

## API 配置

### 一键安装版

首次运行时会使用默认配置。如需修改：

1. 点击菜单栏图标 > 设置 API
2. 输入你的 API 配置
3. 保存后自动切换到自定义模式

### 源码安装版

首次运行后，在设置中配置你的 API：

| 配置项 | 说明 | 示例 |
|--------|------|------|
| API 地址 | 大模型 API 端点 | `https://dashscope.aliyuncs.com/compatible-mode/v1` |
| API Key | 你的 API 密钥 | 从对应平台获取 |
| 模型名称 | 使用的模型 | `qwen-turbo`, `moonshot-v1-8k-vision-preview` |

### 支持的 API

- **通义千问**: `https://dashscope.aliyuncs.com/compatible-mode/v1`
- **Kimi**: `https://api.moonshot.cn/v1`
- **OpenAI**: `https://api.openai.com/v1`
- **Claude**: `https://api.anthropic.com/v1`

---

## 使用说明

### 首次运行

1. 应用会在菜单栏显示图标
2. 首次运行时系统会请求辅助功能权限
3. 前往 "系统设置 > 隐私与安全性 > 辅助功能"，添加 TextPolish

### 基本使用

1. 在任意应用中选中需要处理的文字
2. 按 `⌘F1` - `⌘F5` 中的任意快捷键
3. 等待处理，结果显示在弹窗中

### 操作说明

- **复制结果**: 点击 "复制结果" 按钮
- **替换原文**: 点击 "替换原文" 自动粘贴替换
- **自定义快捷键**: 点击菜单栏 > 快捷键配置 > 管理所有快捷键

---

## 环境变量

如需通过环境变量配置 API（适用于一键安装版自定义部署）：

```bash
export TEXT_POLISH_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
export TEXT_POLISH_API_KEY="your-api-key"
export TEXT_POLISH_MODEL="qwen-turbo"
```

---

## 权限说明

首次运行时需要授权**辅助功能权限**，用于获取选中的文本。

在 "系统设置 > 隐私与安全性 > 辅助功能" 中添加 TextPolish 应用。

---

## 技术栈

- **开发语言**: Swift 5.9+
- **最低系统**: macOS 12.0+
- **依赖**: [HotKey](https://github.com/soffes/HotKey) - 全局快捷键监听

---

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
