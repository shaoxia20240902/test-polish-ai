import Foundation

/// 默认 API 配置（一键安装版使用）
/// ⚠️ 注意：API Key 不应硬编码在代码中，应通过环境变量或配置文件设置
struct DefaultAPIConfig {
    static var baseURL: String {
        // 支持通过环境变量覆盖
        if let url = ProcessInfo.processInfo.environment["TEXT_POLISH_BASE_URL"], !url.isEmpty {
            return url
        }
        return UserDefaults.standard.string(forKey: "defaultBaseURL") ?? "https://api.minimax.chat/v1"
    }

    static var apiKey: String {
        // 优先使用环境变量，其次使用预配置
        // 注意：生产环境应通过安全方式获取 API Key
        if let key = ProcessInfo.processInfo.environment["TEXT_POLISH_API_KEY"], !key.isEmpty {
            return key
        }
        return UserDefaults.standard.string(forKey: "defaultAPIKey") ?? ""
    }

    static var model: String {
        if let model = ProcessInfo.processInfo.environment["TEXT_POLISH_MODEL"], !model.isEmpty {
            return model
        }
        return UserDefaults.standard.string(forKey: "defaultModel") ?? "abab6.5s-chat"
    }

    /// 初始化默认配置（仅首次运行时调用）
    /// - Parameters:
    ///   - baseURL: API 地址
    ///   - apiKey: API 密钥
    ///   - model: 模型名称
    static func initializeDefault(baseURL: String, apiKey: String, model: String) {
        UserDefaults.standard.set(baseURL, forKey: "defaultBaseURL")
        UserDefaults.standard.set(apiKey, forKey: "defaultAPIKey")
        UserDefaults.standard.set(model, forKey: "defaultModel")
    }
}
