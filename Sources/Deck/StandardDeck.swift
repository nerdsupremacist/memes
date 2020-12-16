
import Foundation
import Model

public class StandardDeck: Deck {
    private var playedImages: Set<URL> = []
    private var playedCardText: Set<String> = []

    public let memes: [URL]
    public let captions: [String]

    public init(memes: [URL], captions: [String]) {
        self.memes = memes
        self.captions = captions
    }

    public func reshuffle() {
        playedImages = []
        playedCardText = []
    }

    public func card() -> Card {
        if Int.random(in: 0...100) < 2 {
            return .freestyle
        }

        var caption: String
        repeat {
            caption = captions.randomElement()!
        } while playedCardText.contains(caption)

        playedCardText.formUnion([caption])
        return .text(caption)
    }

    public func meme() -> URL {
        var url: URL
        repeat {
            url = memes.randomElement()!
        } while playedImages.contains(url)

        playedImages.formUnion([url])
        return url
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
            .appendingPathComponent("decks")
    }

    private static let folderURL: URL = {
        return url()
    }()
    #else
    private static let folderURL: URL = URL(fileURLWithPath: "decks")
    #endif

    public func save(as name: String) throws {
        let url = Self.folderURL.appendingPathComponent("\(name).json")
        let data = try JSONEncoder().encode(Export(memes: memes, captions: captions))
        try data.write(to: url)
    }

    public static func with(name: String) throws -> StandardDeck {
        let url = folderURL.appendingPathComponent("\(name).json")
        return try StandardDeck(url: url)
    }

    public static let main: StandardDeck = {
        return try! with(name: "main")
    }()

    public static func all() throws -> [String : StandardDeck] {
        let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
        let sequence = try files
            .filter { $0.pathExtension == "json" }
            .map { ($0.deletingPathExtension().lastPathComponent, try StandardDeck(url: $0)) }

        return Dictionary(uniqueKeysWithValues: sequence)
    }

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

extension StandardDeck {

    private convenience init(url: URL) throws {
        let data = try Data(contentsOf: url)
        let export = try JSONDecoder().decode(StandardDeck.Export.self, from: data)
        self.init(from: export)
    }

}
