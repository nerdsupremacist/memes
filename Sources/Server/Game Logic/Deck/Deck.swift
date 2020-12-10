
import Foundation
import Model

protocol Deck {
    func reshuffle()
    func card(for player: Player, in game: Game) -> Card
    func meme(for judge: Player, in game: Game) -> Meme
}
