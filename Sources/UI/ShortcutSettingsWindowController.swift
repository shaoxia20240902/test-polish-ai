import AppKit
import Carbon.HIToolbox

class ShortcutSettingsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {

    private var configs: [ShortcutConfig] = []
    private var tableView: NSTableView!

    private let configId: String?

    init(configId: String?) {
        self.configId = configId

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 350),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "快捷键配置"
        window.center()
        window.minSize = NSSize(width: 500, height: 300)

        super.init(window: window)
        setupUI()
        loadConfigs()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let scrollView = NSScrollView()
        tableView = NSTableView()
        tableView.dataSource = self
        tableView.delegate = self

        let enabledColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("enabled"))
        enabledColumn.title = "启用"
        enabledColumn.width = 50

        let keyColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("key"))
        keyColumn.title = "快捷键"
        keyColumn.width = 80

        let actionColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("action"))
        actionColumn.title = "功能"
        actionColumn.width = 150

        let promptColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("prompt"))
        promptColumn.title = "自定义 Prompt"
        promptColumn.width = 250

        tableView.addTableColumn(enabledColumn)
        tableView.addTableColumn(keyColumn)
        tableView.addTableColumn(actionColumn)
        tableView.addTableColumn(promptColumn)

        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder

        let saveButton = NSButton(title: "保存", target: self, action: #selector(saveConfigs))
        let closeButton = NSButton(title: "关闭", target: self, action: #selector(closeWindow))

        let buttonStack = NSStackView(views: [saveButton, closeButton])
        buttonStack.spacing = 12

        let mainStack = NSStackView(views: [scrollView, buttonStack])
        mainStack.orientation = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250)
        ])
    }

    private func loadConfigs() {
        configs = ShortcutConfigManager.shared.load()
        tableView.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return configs.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let config = configs[row]
        let identifier = tableColumn?.identifier

        if identifier?.rawValue == "enabled" {
            let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(enabledChanged(_:)))
            checkbox.state = config.isEnabled ? .on : .off
            checkbox.tag = row
            return checkbox
        } else if identifier?.rawValue == "key" {
            let popup = NSPopUpButton(frame: .zero, pullsDown: false)
            popup.addItems(withTitles: ["F1", "F2", "F3", "F4", "F5"])
            let keyCodes = [UInt32(kVK_F1), UInt32(kVK_F2), UInt32(kVK_F3), UInt32(kVK_F4), UInt32(kVK_F5)]
            if let index = keyCodes.firstIndex(of: config.keyCode) {
                popup.selectItem(at: index)
            }
            popup.tag = row
            popup.target = self
            popup.action = #selector(keyChanged(_:))
            return popup
        } else if identifier?.rawValue == "action" {
            let popup = NSPopUpButton(frame: .zero, pullsDown: false)
            popup.addItems(withTitles: ShortcutAction.allCases.map { $0.displayName })
            if let index = ShortcutAction.allCases.firstIndex(of: config.action) {
                popup.selectItem(at: index)
            }
            popup.tag = row
            popup.target = self
            popup.action = #selector(actionChanged(_:))
            return popup
        } else if identifier?.rawValue == "prompt" {
            let textField = NSTextField()
            textField.stringValue = config.customPrompt ?? config.action.prompt
            textField.tag = row
            textField.target = self
            textField.action = #selector(promptChanged(_:))
            return textField
        }

        return nil
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }

    @objc private func enabledChanged(_ sender: NSButton) {
        let row = sender.tag
        configs[row].isEnabled = (sender.state == .on)
    }

    @objc private func keyChanged(_ sender: NSPopUpButton) {
        let row = sender.tag
        let keyCodes = [UInt32(kVK_F1), UInt32(kVK_F2), UInt32(kVK_F3), UInt32(kVK_F4), UInt32(kVK_F5)]
        configs[row].keyCode = keyCodes[sender.indexOfSelectedItem]
    }

    @objc private func actionChanged(_ sender: NSPopUpButton) {
        let row = sender.tag
        configs[row].action = ShortcutAction.allCases[sender.indexOfSelectedItem]
    }

    @objc private func promptChanged(_ sender: NSTextField) {
        let row = sender.tag
        configs[row].customPrompt = sender.stringValue.isEmpty ? nil : sender.stringValue
    }

    @objc private func saveConfigs() {
        ShortcutConfigManager.shared.save(configs)
        window?.close()
        NotificationCenter.default.post(name: .shortcutConfigChanged, object: nil)
    }

    @objc private func closeWindow() {
        window?.close()
    }
}
