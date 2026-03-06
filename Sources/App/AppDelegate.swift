import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        NSApp.setActivationPolicy(.accessory)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shortcutConfigChanged),
            name: .shortcutConfigChanged,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregister()
    }

    @objc private func shortcutConfigChanged() {
        statusBarController?.refresh()
    }
}
