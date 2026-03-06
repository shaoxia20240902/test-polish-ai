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
            let modifiers = NSEvent.ModifierFlags.command

            let hotKey = HotKey(key: key, modifiers: modifiers)
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
