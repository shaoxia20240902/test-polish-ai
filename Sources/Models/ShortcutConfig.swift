import Foundation
import Carbon.HIToolbox

/// 快捷键功能类型
enum ShortcutAction: String, Codable, CaseIterable {
    case polish = "polish"
    case summarize = "summarize"
    case formalize = "formalize"
    case codeExplain = "codeExplain"
    case translate = "translate"

    var displayName: String {
        switch self {
        case .polish: return "通用润色"
        case .summarize: return "精简总结"
        case .formalize: return "正式改写"
        case .codeExplain: return "代码注释"
        case .translate: return "中英翻译"
        }
    }

    var prompt: String {
        switch self {
        case .polish:
            return "请润色以下文字，使其表达更清晰、更专业、更流畅。"
        case .summarize:
            return "请精简以下内容，保留核心信息，压缩为简洁版本。"
        case .formalize:
            return "请将以下内容改写为更正式、书面的表达方式。"
        case .codeExplain:
            return "请解释以下代码的含义，并优化注释（如无代码则进行专业解释）。"
        case .translate:
            return "请将以下内容翻译为英文（如果是英文则翻译为中文），保持原意。"
        }
    }
}

/// 单个快捷键配置
struct ShortcutConfig: Codable, Identifiable {
    var id: String
    var action: ShortcutAction
    var keyCode: UInt32
    var modifiers: UInt32
    var isEnabled: Bool
    var customPrompt: String?

    static func defaultConfigs() -> [ShortcutConfig] {
        return [
            ShortcutConfig(id: "1", action: .polish, keyCode: UInt32(kVK_F1), modifiers: UInt32(cmdKey), isEnabled: true),
            ShortcutConfig(id: "2", action: .summarize, keyCode: UInt32(kVK_F2), modifiers: UInt32(cmdKey), isEnabled: true),
            ShortcutConfig(id: "3", action: .formalize, keyCode: UInt32(kVK_F3), modifiers: UInt32(cmdKey), isEnabled: true),
            ShortcutConfig(id: "4", action: .codeExplain, keyCode: UInt32(kVK_F4), modifiers: UInt32(cmdKey), isEnabled: true),
            ShortcutConfig(id: "5", action: .translate, keyCode: UInt32(kVK_F5), modifiers: UInt32(cmdKey), isEnabled: true)
        ]
    }
}

/// 快捷键配置管理器
class ShortcutConfigManager {
    static let shared = ShortcutConfigManager()

    private let userDefaultsKey = "shortcutConfigs"

    private init() {}

    func load() -> [ShortcutConfig] {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let configs = try? JSONDecoder().decode([ShortcutConfig].self, from: data) {
            return configs
        }
        return ShortcutConfig.defaultConfigs()
    }

    func save(_ configs: [ShortcutConfig]) {
        if let data = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func update(_ config: ShortcutConfig) {
        var configs = load()
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
            save(configs)
        }
    }
}
