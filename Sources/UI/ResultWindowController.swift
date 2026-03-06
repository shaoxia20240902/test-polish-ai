import AppKit

class ResultWindowController: NSWindowController {

    private var originalTextView: NSTextView!
    private var processedTextView: NSTextView!
    private var actionLabel: NSTextField!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 450),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "处理结果"
        window.center()
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 500, height: 350)

        self.init(window: window)
        setupUI()
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        actionLabel = NSTextField(labelWithString: "处理结果")
        actionLabel.font = NSFont.boldSystemFont(ofSize: 16)

        let originalLabel = NSTextField(labelWithString: "原文")
        originalLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)

        let originalScrollView = NSScrollView()
        originalTextView = NSTextView()
        originalTextView.isEditable = false
        originalTextView.font = NSFont.systemFont(ofSize: 13)
        originalTextView.textContainerInset = NSSize(width: 8, height: 8)
        originalScrollView.documentView = originalTextView
        originalScrollView.hasVerticalScroller = true
        originalScrollView.borderType = .bezelBorder

        let processedLabel = NSTextField(labelWithString: "处理后")
        processedLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)

        let processedScrollView = NSScrollView()
        processedTextView = NSTextView()
        processedTextView.isEditable = true
        processedTextView.font = NSFont.systemFont(ofSize: 13)
        processedTextView.textContainerInset = NSSize(width: 8, height: 8)
        processedScrollView.documentView = processedTextView
        processedScrollView.hasVerticalScroller = true
        processedScrollView.borderType = .bezelBorder

        let copyButton = NSButton(title: "复制结果", target: self, action: #selector(copyProcessedText))
        let replaceButton = NSButton(title: "替换原文", target: self, action: #selector(replaceOriginal))
        let closeButton = NSButton(title: "关闭", target: self, action: #selector(closeWindow))

        let buttonStack = NSStackView(views: [copyButton, replaceButton, closeButton])
        buttonStack.spacing = 12

        let originalStack = NSStackView(views: [originalLabel, originalScrollView])
        originalStack.orientation = .vertical
        originalStack.alignment = .leading
        originalStack.spacing = 4

        let processedStack = NSStackView(views: [processedLabel, processedScrollView])
        processedStack.orientation = .vertical
        processedStack.alignment = .leading
        processedStack.spacing = 4

        let textStack = NSStackView(views: [originalStack, processedStack])
        textStack.orientation = .horizontal
        textStack.distribution = .fillEqually
        textStack.spacing = 16

        let mainStack = NSStackView(views: [actionLabel, textStack, buttonStack])
        mainStack.orientation = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            originalScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250),
            processedScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250)
        ])
    }

    func show(original: String, processed: String, action: ShortcutAction) {
        actionLabel.stringValue = action.displayName + "结果"
        originalTextView.string = original
        processedTextView.string = processed

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func copyProcessedText() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(processedTextView.string, forType: .string)
    }

    @objc private func replaceOriginal() {
        let processedText = processedTextView.string
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(processedText, forType: .string)

        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(9), keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(9), keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)

        window?.close()
    }

    @objc private func closeWindow() {
        window?.close()
    }
}
