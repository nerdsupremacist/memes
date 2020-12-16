
import Foundation
import JavaScriptKit

extension URLComponents {

    static var current: URLComponents? {
        get {
            let window = JSObject.global.window.object!
            return window["location"].object?["href"].string.flatMap(URLComponents.init(string:))
        }
        set {
            if let string = newValue?.string {
                let window = JSObject.global.window.object!
                _ = window["history"].object!.replaceState?([:], "", string)
            }
        }
    }

}

extension URLComponents {

    static func changeQueryParameters(_ closure: ([URLQueryItem]) -> [URLQueryItem]) {
        guard var components = current else { return }
        components.queryItems = closure(components.queryItems ?? [])
        if components.query!.isEmpty {
            components.queryItems = nil
        }
        current = components
    }

}
