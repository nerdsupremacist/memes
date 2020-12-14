
import Foundation
import Model

class StandardDeck: Deck {
    private var playedImages: Set<URL> = []
    private var playedCardText: Set<String> = []
    private let memes: [URL]
    private let captions: [String]

    init(memes: [URL], captions: [String]) {
        self.memes = memes
        self.captions = captions
    }

    func reshuffle() {
        playedImages = []
        playedCardText = []
    }

    func card(for player: Player, in game: Game) -> Card {
        if Int.random(in: 0...100) < 1 {
            return .freestyle
        }

        var caption: String
        repeat {
            caption = captions.randomElement()!
        } while playedCardText.contains(caption)

        playedCardText.formUnion([caption])
        return .text(caption)
    }

    func meme(for judge: Player, in game: Game) -> Meme {
        var url: URL
        repeat {
            url = memes.randomElement()!
        } while playedImages.contains(url)

        playedImages.formUnion([url])
        return Meme(judge: judge, image: url)
    }
}

extension StandardDeck {

    #if os(macOS)
    private static func url(_ file: String = #file) -> URL {
        let url = URL(fileURLWithPath: file)
        return url
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("deck.json")
    }

    private static let deckURL: URL = {
        return url()
    }()
    #else
    private static let deckURL: URL = URL(fileURLWithPath: "deck.json")
    #endif

    static let basic: StandardDeck = {
        let data = try! Data(contentsOf: deckURL)
        let export = try! JSONDecoder().decode(StandardDeck.Export.self, from: data)
        return StandardDeck(from: export)
    }()
}

extension StandardDeck {
    private struct Export: Codable {
        let memes: [URL]
        let captions: [String]
    }

    private convenience init(from export: Export) {
        self.init(memes: export.memes, captions: export.captions)
    }
}
