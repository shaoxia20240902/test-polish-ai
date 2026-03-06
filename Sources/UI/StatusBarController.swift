import AppKit
import Carbon.HIToolbox

class StatusBarController {

    private var statusItem: NSStatusItem
    private var resultWindow: ResultWindowController?
    private let polishService = PolishService()

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupButton()
        setupMenu()
        setupHotKey()
    }

    private func setupButton() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "wand.and.stars", accessibilityDescription: "文本润色")
            button.imagePosition = .imageLeading

            let shortcutText = buildShortcutHint()
            button.title = " \(shortcutText)"
        }
    }

    private func buildShortcutHint() -> String {
        let configs = ShortcutConfigManager.shared.load()
        let enabledConfigs = configs.filter { $0.isEnabled }

        return enabledConfigs.map { config in
            let keyName = keyCodeToString(config.keyCode)
            return "\(keyName)\(config.action.displayName)"
        }.joined(separator: " | ")
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        switch keyCode {
        case UInt32(kVK_F1): return "F1"
        case UInt32(kVK_F2): return "F2"
        case UInt32(kVK_F3): return "F3"
        case UInt32(kVK_F4): return "F4"
        case UInt32(kVK_F5): return "F5"
        default: return "F\(keyCode)"
        }
    }

    private func setupMenu() {
        let menu = NSMenu()

        let shortcutMenu = NSMenu()
        let configs = ShortcutConfigManager.shared.load()
        for config in configs {
            let item = NSMenuItem(title: "⌘\(keyCodeToString(config.keyCode)) \(config.action.displayName)",
                                  action: #selector(configureShortcut(_:)),
                                  keyEquivalent: "")
            item.tag = Int(config.id) ?? 0
            item.target = self
            item.isEnabled = true
            shortcutMenu.addItem(item)
        }
        shortcutMenu.addItem(NSMenuItem.separator())
        shortcutMenu.addItem(NSMenuItem(title: "管理所有快捷键...", action: #selector(openShortcutSettings), keyEquivalent: ""))

        let shortcutItem = NSMenuItem(title: "快捷键配置", action: nil, keyEquivalent: "")
        shortcutItem.submenu = shortcutMenu
        menu.addItem(shortcutItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "设置 API...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "关于", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func setupHotKey() {
        HotKeyManager.shared.onHotKeyPressed = { [weak self] action in
            self?.handleHotKey(action: action)
        }
        HotKeyManager.shared.register()
    }

    private func handleHotKey(action: ShortcutAction) {
        guard let selectedText = TextExtractor.getSelectedText() else {
            showNotification(title: "未找到选中文本", body: "请先选中需要处理的文字")
            return
        }

        polishService.polish(text: selectedText, action: action) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let processedText):
                    self?.showResult(original: selectedText, processed: processedText, action: action)
                case .failure(let error):
                    self?.showNotification(title: "处理失败", body: error.localizedDescription)
                }
            }
        }
    }

    private func showResult(original: String, processed: String, action: ShortcutAction) {
        if resultWindow == nil {
            resultWindow = ResultWindowController()
        }
        resultWindow?.show(original: original, processed: processed, action: action)
    }

    private func showNotification(title: String, body: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        NSUserNotificationCenter.default.deliver(notification)
    }

    @objc private func configureShortcut(_ sender: NSMenuItem) {
        let configId = String(sender.tag)
        let settingsWindow = ShortcutSettingsWindowController(configId: configId)
        settingsWindow.showWindow(nil)
    }

    @objc private func openShortcutSettings() {
        let settingsWindow = ShortcutSettingsWindowController(configId: nil)
        settingsWindow.showWindow(nil)
    }

    @objc private func openSettings() {
        let settingsWindow = SettingsWindowController()
        settingsWindow.showWindow(nil)
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    func refresh() {
        setupButton()
        HotKeyManager.shared.reregister()
    }
}

extension Notification.Name {
    static let shortcutConfigChanged = Notification.Name("shortcutConfigChanged")
}
