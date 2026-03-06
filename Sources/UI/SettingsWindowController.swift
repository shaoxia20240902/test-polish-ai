import AppKit

class SettingsWindowController: NSWindowController {

    private var baseURLField: NSTextField!
    private var apiKeyField: NSTextField!
    private var modelField: NSTextField!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "API 设置"
        window.center()

        self.init(window: window)
        setupUI()
        loadConfig()
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let baseURLLabel = NSTextField(labelWithString: "API 地址:")
        baseURLLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        baseURLField = NSTextField()
        baseURLField.placeholderString = "https://dashscope.aliyuncs.com/compatible-mode/v1"

        let apiKeyLabel = NSTextField(labelWithString: "API Key:")
        apiKeyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        apiKeyField = NSTextField()
        apiKeyField.placeholderString = "输入你的 API Key"

        let modelLabel = NSTextField(labelWithString: "模型名称:")
        modelLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        modelField = NSTextField()
        modelField.placeholderString = "如: qwen-turbo, moonshot-v1-8k-vision-preview"

        let saveButton = NSButton(title: "保存", target: self, action: #selector(saveConfig))
        saveButton.keyEquivalent = "\r"

        let cancelButton = NSButton(title: "取消", target: self, action: #selector(cancel))
        cancelButton.keyEquivalent = "\u{1b}"

        let grid = NSGridView(views: [
            [baseURLLabel, baseURLField],
            [apiKeyLabel, apiKeyField],
            [modelLabel, modelField]
        ])
        grid.rowSpacing = 12
        grid.columnSpacing = 8
        grid.column(at: 0).xPlacement = .trailing
        grid.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = NSStackView(views: [saveButton, cancelButton])
        buttonStack.spacing = 12

        let mainStack = NSStackView(views: [grid, buttonStack])
        mainStack.orientation = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            baseURLField.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            apiKeyField.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            modelField.widthAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }

    private func loadConfig() {
        let config = APIConfig.load()
        baseURLField.stringValue = config.baseURL
        apiKeyField.stringValue = config.apiKey
        modelField.stringValue = config.model
    }

    @objc private func saveConfig() {
        let config = APIConfig(
            baseURL: baseURLField.stringValue,
            apiKey: apiKeyField.stringValue,
            model: modelField.stringValue
        )
        config.save()

        window?.close()
    }

    @objc private func cancel() {
        window?.close()
    }
}
