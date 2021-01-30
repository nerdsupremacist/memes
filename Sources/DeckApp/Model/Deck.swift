
import Foundation
import Deck

class Deck: ObservableObject {
    let queue: OperationQueue
    let name: String

    @Published
    var memes: [Meme]

    @Published
    var captions: [Caption]

    init(name: String, from deck: StandardDeck) {
        self.name = name
        self.memes = deck.memes.map(Meme.init(image:))
        self.captions = deck.captions.map(Caption.init(text:))
        self.queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
    }

    func save() {
        queue.addOperation {
            let deck = StandardDeck(memes: self.memes.map(\.image).removeDuplicates(), captions: self.captions.map(\.text))
            _ = try? deck.save(as: self.name)
        }
    }
}

extension Collection where Element: Hashable {

    func removeDuplicates() -> [Element] {
        var set: Set<Element> = []
        var result: [Element] = []

        for element in self where !set.contains(element) {
            set.formUnion([element])
            result.append(element)
        }

        return result
    }

}
