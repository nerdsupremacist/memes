
import Foundation
import JavaScriptKit

enum Clipboard {
    private static let clipboard = JSObject.global.navigator.object!["clipboard"].object!

    static func write(_ text: String) {
        _ = clipboard.writeText!(text)
    }
}
