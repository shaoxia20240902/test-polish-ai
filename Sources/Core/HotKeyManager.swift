import AppKit
import Carbon
import Carbon.HIToolbox

class HotKeyManager {

    static let shared = HotKeyManager()

    private var hotKeys: [String: HotKey] = [:]
    var onHotKeyPressed: ((ShortcutAction) -> Void)?

    private init() {}

    func register() {
        unregister()

        let configs = ShortcutConfigManager.shared.load()

        for config in configs where config.isEnabled {
            let key = Key(carbonKeyCode: config.keyCode)

            // 从配置中获取 modifiers 并转换为 NSEvent.ModifierFlags
            var flags: NSEvent.ModifierFlags = []
            if config.modifiers & UInt32(cmdKey) != 0 {
                flags.insert(.command)
            }
            if config.modifiers & UInt32(shiftKey) != 0 {
                flags.insert(.shift)
            }
            if config.modifiers & UInt32(optionKey) != 0 {
                flags.insert(.option)
            }
            if config.modifiers & UInt32(controlKey) != 0 {
                flags.insert(.control)
            }

            let hotKey = HotKey(key: key, modifiers: flags)
            hotKey.keyDownHandler = { [weak self] in
                self?.onHotKeyPressed?(config.action)
            }

            hotKeys[config.id] = hotKey
        }
    }

    func unregister() {
        hotKeys.removeAll()
    }

    func reregister() {
        register()
    }
}
