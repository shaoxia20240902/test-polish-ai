class TextPolish < Formula
  desc "macOS text polish tool with LLM API support"
  homepage "https://github.com/shaoxia20240902/test-polish-ai"
  url "https://github.com/shaoxia20240902/test-polish-ai.git"
  version "1.0.0"
  license "MIT"

  # 一键安装版默认配置 (MiniMax M2.5)
  # 用户可通过环境变量覆盖：
  # TEXT_POLISH_BASE_URL, TEXT_POLISH_API_KEY, TEXT_POLISH_MODEL
  def default_api_config
    {
      base_url: ENV["TEXT_POLISH_BASE_URL"] || "https://api.minimax.chat/v1",
      api_key: ENV["TEXT_POLISH_API_KEY"] || "",
      model: ENV["TEXT_POLISH_MODEL"] || "abab6.5s-chat"
    }
  end

  def install
    # 生成项目
    system "xcodegen", "generate"

    # 安装依赖
    system "swift", "package", "resolve"

    # 构建
    system "xcodebuild", "-project", "TextPolish.xcodeproj",
           "-scheme", "TextPolish",
           "-configuration", "Release",
           "build",
           "DESTINATION=generic/platform=macOS"

    # 复制构建产物
    bin.install "build/Release/TextPolish.app"
  end

  def post_install
    # 保存默认 API 配置
    config = default_api_config
    # 将默认配置写入用户配置（首次安装时使用）
    # 用户可在设置中覆盖
  end

  def caveats
    <<~EOS
      一键安装版默认使用预配置的大模型 API。

      如需使用自己的 API Key：
      1. 点击菜单栏图标 > 设置 API
      2. 输入自己的 API 配置

      也可通过环境变量覆盖：
      TEXT_POLISH_BASE_URL=https://api.example.com/v1 \\
      TEXT_POLISH_API_KEY=your-api-key \\
      TEXT_POLISH_MODEL=model-name
    EOS
  end
end
