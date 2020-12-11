
import Foundation
import Model

public enum ClientEvent {
    case join(id: GameID)
    case configure(rounds: Int)
    case register(name: String)
    case start
    case play(Card)
    case freestyle(String)
    case choose(String)
    case playAgain
    case stop
}

extension ClientEvent {
    enum Kind: String, Codable {
        case join
        case register
        case configure
        case start
        case play
        case freestyle
        case choose
        case playAgain
        case stop
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case id
        case rounds
        case name
        case card
        case text
    }
}

extension ClientEvent: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .join(let id):
            try container.encode(Kind.join, forKey: .kind)
            try container.encode(id, forKey: .id)
        case .configure(let rounds):
            try container.encode(Kind.configure, forKey: .kind)
            try container.encode(rounds, forKey: .rounds)
        case .register(let name):
            try container.encode(Kind.register, forKey: .kind)
            try container.encode(name, forKey: .name)
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
        case .playAgain:
            try container.encode(Kind.playAgain, forKey: .kind)
        case .stop:
            try container.encode(Kind.stop, forKey: .kind)
        }
    }
}

extension ClientEvent: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .join:
            self = .join(id: try container.decode(GameID.self, forKey: .id))
        case .configure:
            self = .configure(rounds: try container.decode(Int.self, forKey: .rounds))
        case .register:
            self = .register(name: try container.decode(String.self, forKey: .name))
        case .start:
            self = .start
        case .play:
            self = .play(try container.decode(Card.self, forKey: .card))
        case .freestyle:
            self = .freestyle(try container.decode(String.self, forKey: .text))
        case .choose:
            self = .choose(try container.decode(String.self, forKey: .text))
        case .playAgain:
            self = .playAgain
        case .stop:
            self = .stop
        }
    }
}
