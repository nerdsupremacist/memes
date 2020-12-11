
import Foundation
import TokamakDOM
import JavaScriptKit
import Model

let document = JSObject.global.document
_ = document.head.object!.insertAdjacentHTML!("beforeend", #"""
<style>
span {
    white-space: normal;
}
</style>
"""#)

struct Memes: App {
    let session: Session

    init() {
        #if DEBUG
        session = Session(id: gameIDFromURL(), url: URL(string: "ws://localhost:3000/game")!)
        #else
        session = Session(id: gameIDFromURL(), url: URL(string: "wss://memes.apps.quintero.io/game")!)
        #endif
    }

    var body: some Scene {
        WindowGroup("Memes") {
            RootView(session: session)
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
