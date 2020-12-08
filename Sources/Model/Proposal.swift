
import Foundation

public struct Proposal: Codable {
    public let player: Player
    public let text: String
    
    public init(player: Player, text: String) {
        self.player = player
        self.text = text
    }
}
