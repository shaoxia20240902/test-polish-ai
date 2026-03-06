import Foundation

class PolishService {

    private let config: APIConfig

    init(config: APIConfig = .load()) {
        self.config = config
    }

    func polish(text: String, action: ShortcutAction, customPrompt: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard !config.apiKey.isEmpty else {
            completion(.failure(PolishError.noAPIKey))
            return
        }

        let endpoint = "\(config.baseURL)/chat/completions"

        guard let url = URL(string: endpoint) else {
            completion(.failure(PolishError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        let systemPrompt = customPrompt ?? action.prompt
        let userPrompt = """
        \(systemPrompt)

        原始文本：
        \(text)

        请直接返回处理后的结果，不要添加任何解释、前缀或总结。
        """

        let body: [String: Any] = [
            "model": config.model,
            "messages": [
                ["role": "system", "content": "你是一个专业的文字处理助手，擅长润色、总结、改写、解释和翻译。"],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(PolishError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        print("API Error: \(errorMessage)")
                    }
                    completion(.failure(PolishError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum PolishError: LocalizedError {
    case noAPIKey
    case invalidURL
    case noData
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "请先在设置中配置 API Key"
        case .invalidURL: return "无效的 API 地址"
        case .noData: return "未收到服务器响应"
        case .invalidResponse: return "服务器响应格式错误"
        }
    }
}
