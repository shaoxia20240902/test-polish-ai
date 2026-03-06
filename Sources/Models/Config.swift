import Foundation

struct APIConfig: Codable {
    var baseURL: String
    var apiKey: String
    var model: String

    static let defaultConfig = APIConfig(
        baseURL: "https://dashscope.aliyuncs.com/compatible-mode/v1",
        apiKey: "",
        model: "qwen-turbo"
    )

    static func load() -> APIConfig {
        if let data = UserDefaults.standard.data(forKey: "apiConfig"),
           let config = try? JSONDecoder().decode(APIConfig.self, from: data) {
            return config
        }
        return defaultConfig
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "apiConfig")
        }
    }
}
