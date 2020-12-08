
import Foundation

struct Player: Codable {
    var id: String
    var emoji: String
    var name: String
    var winCount: Int
    var isHost: Bool
}
