
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

<script async src="https://www.googletagmanager.com/gtag/js?id=G-H3T3MC2E5E"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-H3T3MC2E5E');
</script>
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
    guard let components = URLComponents.current else { return nil }
    return components.queryItems?.first { $0.name == "id" }?.value.map(GameID.init(rawValue:))
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
Memes.main()
