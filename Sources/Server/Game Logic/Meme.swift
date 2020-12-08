
import Foundation

class Meme {
    unowned var judge: Player
    let image: URL
    var proposedLines: [Proposal] = []
    var winningCard: Proposal? = nil

    init(judge: Player, image: URL) {
        self.judge = judge
        self.image = image
    }
}
