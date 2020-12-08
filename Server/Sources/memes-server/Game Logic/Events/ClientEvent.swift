
import Foundation

enum ClientEvent {
    case join(id: GameID)
    case configure(rounds: Int)
    case register(name: String, emoji: String)
    case start
    case play(Card)
    case freestyle(String)
    case choose(String)
    case end
}

extension ClientEvent: Decodable {

    enum Kind: String, Decodable {
        case join
        case configure
        case register
        case start
        case play
        case freestyle
        case choose
        case end
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case id
        case rounds
        case name
        case emoji
        case card
        case text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .join:
            self = .join(id: try container.decode(GameID.self, forKey: .id))
        case .configure:
            self = .configure(rounds: try container.decode(Int.self, forKey: .rounds))
        case .register:
            self = .register(name: try container.decode(String.self, forKey: .name), emoji: try container.decode(String.self, forKey: .emoji))
        case .start:
            self = .start
        case .play:
            self = .play(try container.decode(Card.self, forKey: .card))
        case .freestyle:
            self = .freestyle(try container.decode(String.self, forKey: .text))
        case .choose:
            self = .choose(try container.decode(String.self, forKey: .text))
        case .end:
            self = .end
        }
    }

}
