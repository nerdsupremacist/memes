
import Foundation
import SwiftUI
import Deck

struct DeckApp: App {
    let decks: [Deck]

    init() {
        self.decks = try! StandardDeck
            .all()
            .sorted { $0.key < $1.key }
            .map { Deck(name: $0.key, from: $0.value) }
    }

    var body: some Scene {
        WindowGroup {
            RootView(decks: decks)
        }
    }
}

NSApplication.shared.run(DeckApp.self)
