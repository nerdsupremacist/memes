import Foundation
import TokamakDOM
import OpenCombine
import JavaScriptKit
import Model

struct Memes: App {
    let game: Game

    init() {
        #if DEBUG
        game = Game(id: gameIDFromURL(), webSocket: WebSocket(url: URL(string: "ws://localhost:3000/game")!))
        #else
        game = Game(id: gameIDFromURL(), webSocket: WebSocket(url: URL(string: "wss://memes.apps.quintero.io/game")!))
        #endif
    }

    var body: some Scene {
        WindowGroup("Memes") {
            GameRootView(game: game)
        }
    }
}

private func gameIDFromURL() -> GameID? {
    let window = JSObject.global.window.object!
    guard let components = window["location"].object?["href"].string.flatMap(URLComponents.init(string:)) else { return nil }
    return components.queryItems?.first { $0.name == "id" }?.value.map(GameID.init(rawValue:))
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
Memes.main()
