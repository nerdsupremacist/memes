
import Foundation

protocol Deck {
    func card(for player: Player, in game: Game) -> Card
    func meme(for judge: Player, in game: Game) -> Meme
}
