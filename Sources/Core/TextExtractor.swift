import AppKit
import Carbon

class TextExtractor {

    /// 获取当前聚焦应用选中的文本
    static func getSelectedText() -> String? {
        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.string(forType: .string)

        // 模拟 Cmd+C
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(8), keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(8), keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)

        // 等待复制完成
        usleep(100000)

        // 获取新复制的内容
        let selectedText = pasteboard.string(forType: .string)

        // 恢复之前剪贴板内容
        if let previous = previousContents {
            pasteboard.clearContents()
            pasteboard.setString(previous, forType: .string)
        }

        if let text = selectedText, !text.isEmpty {
            return text
        }

        return nil
    }
}
