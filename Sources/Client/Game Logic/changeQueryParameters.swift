
import Foundation
import JavaScriptKit

func changeQueryParameters(_ closure: ([URLQueryItem]) -> [URLQueryItem]) {
    let window = JSObject.global.window.object!
    guard var components = window["location"].object?["href"].string.flatMap(URLComponents.init(string:)) else { return }
    components.queryItems = closure(components.queryItems ?? [])
    if components.query!.isEmpty {
        components.queryItems = nil
    }
    if let string = components.string {
        _ = window["history"].object!.replaceState?([:], "", string)
    }
}
