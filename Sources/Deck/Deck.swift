
import Foundation
import Model

public protocol Deck {
    func reshuffle()
    func card() -> Card
    func meme() -> URL
}
