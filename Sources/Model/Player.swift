
import Foundation

public struct Player: Codable {
    public var id: UUID
    public var emoji: String
    public var name: String
    public var winCount: Int
    public var isHost: Bool

    public init(id: UUID, emoji: String, name: String, winCount: Int, isHost: Bool) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.winCount = winCount
        self.isHost = isHost
    }
}
