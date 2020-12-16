
import Foundation
import SwiftUI
import Deck

struct Meme: Identifiable {
    let id = UUID()
    var image: URL
}

struct Caption: Identifiable {
    let id = UUID()
    var text: String
}

class Deck: ObservableObject {
    let name: String

    @Published
    var memes: [Meme]

    @Published
    var captions: [Caption]

    init(name: String, from deck: StandardDeck) {
        self.name = name
        self.memes = deck.memes.map(Meme.init(image:))
        self.captions = deck.captions.map(Caption.init(text:))
    }

    func save() {
        DispatchQueue.global(qos: .background).async {
            let deck = StandardDeck(memes: self.memes.map(\.image), captions: self.captions.map(\.text))
            _ = try? deck.save(as: self.name)
        }
    }
}

struct CaptionView: View {
    @ObservedObject
    var deck: Deck

    @State
    var selected: Caption?

    var body: some View {
        List(deck.captions, id: \.id, selection: $selected) { caption in
            Text(caption.text)
                .onDeleteCommand {
                    deck.captions.removeFirst { $0 == caption }
                }
        }
        .sheet(item: $selected) { selected in
            Text(selected)
        }
    }
}

struct DeckEdit: View {
    @ObservedObject
    var deck: Deck

    var body: some View {
        TabView {
            CaptionView(deck: deck).tabItem { Text("Captions") }
            CaptionView(deck: deck).tabItem { Text("Captions") }
        }
    }
}

struct ContentView: View {
    let decks: [Deck]

    var body: some View {
        NavigationView {
            List(decks, id: \.name) { deck in
                NavigationLink(deck.name.capitalized, destination: DeckEdit(deck: deck))
            }
            .navigationTitle("Decks")
        }
    }
}


let decks = try! StandardDeck
    .all()
    .sorted { $0.key < $1.key }
    .map { Deck(name: $0.key, from: $0.value) }

NSApplication.shared.run {
    ContentView(decks: decks)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
