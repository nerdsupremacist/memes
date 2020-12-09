import Foundation
import TokamakDOM
import OpenCombine
import JavaScriptKit

struct Memes: App {
    #if DEBUG
    let game = Game(webSocket: WebSocket(url: URL(string: "ws://localhost:3000/game")!))
    #else
    let game = Game(webSocket: WebSocket(url: URL(string: "wss://memes.apps.quintero.io/game")!))
    #endif

    var body: some Scene {
        WindowGroup("Memes") {
            GameRootView(game: game)
        }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
Memes.main()
