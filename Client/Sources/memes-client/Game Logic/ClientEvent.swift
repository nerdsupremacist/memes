
import Foundation

enum ClientEvent {
    case configure(rounds: Int)
    case register(name: String, emoji: String)
    case start
    case play(Card)
    case freestyle(String)
    case choose(String)
    case end
}

extension ClientEvent: Encodable {
    enum Kind: String, Encodable {
        case register
        case configure
        case start
        case play
        case freestyle
        case choose
        case end
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case rounds
        case name
        case emoji
        case card
        case text
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .configure(let rounds):
            try container.encode(Kind.configure, forKey: .kind)
            try container.encode(rounds, forKey: .rounds)
        case .register(let name, let emoji):
            try container.encode(Kind.register, forKey: .kind)
            try container.encode(name, forKey: .name)
            try container.encode(emoji, forKey: .emoji)
        case .start:
            try container.encode(Kind.start, forKey: .kind)
        case .play(let card):
            try container.encode(Kind.play, forKey: .kind)
            try container.encode(card, forKey: .card)
        case .freestyle(let text):
            try container.encode(Kind.freestyle, forKey: .kind)
            try container.encode(text, forKey: .text)
        case .choose(let text):
            try container.encode(Kind.choose, forKey: .kind)
            try container.encode(text, forKey: .text)
        case .end:
            try container.encode(Kind.end, forKey: .kind)
        }
    }
}
