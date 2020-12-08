
import Foundation

enum Card {
    case text(String)
    case freestyle
}

extension Card {

    enum Kind: String, Codable {
        case text
        case freestyle
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case text
    }

}

extension Card: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .freestyle:
            try container.encode(Kind.freestyle, forKey: .kind)
        case .text(let text):
            try container.encode(Kind.text, forKey: .kind)
            try container.encode(text, forKey: .text)
        }
    }

}


extension Card: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .freestyle:
            self = .freestyle
        case .text:
            self = .text(try container.decode(String.self, forKey: .text))
        }
    }

}
