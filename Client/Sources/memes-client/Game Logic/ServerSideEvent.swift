
import Foundation

enum ServerSideEvent {
    case initialized(id: String)
    case successfullyJoined(player: Player)

    case playerJoined(player: Player)
    case playerLeft(player: Player)
    case newHost(player: Player)

    case newCards([Card])

    case collecting(StartMeme)
    case freeStyle(StartMeme)

    case update(UpdateMeme)

    case choosing(ChoosingMeme)
    case chosen(ChosenMeme)

    case judgeChange(Player)

    case error(GameError)
    case end(players: [Player])
}

extension ServerSideEvent {

    struct StartMeme: Decodable {
        let image: URL
        let judge: Player
    }

    struct UpdateMeme: Decodable {
        let submitted: [Player]
    }

    struct ChoosingMeme: Decodable {
        let proposals: [String]
    }

    struct ChosenMeme: Decodable {
        let winner: Proposal
        let others: [Proposal]
    }

}

extension ServerSideEvent: Decodable {
    enum Kind: String, Decodable {
        case initialized
        case successfullyJoined

        case playerJoined
        case playerLeft
        case newHost

        case newCards

        case collecting
        case freeStyle

        case update

        case choosing
        case chosen
        case judgeChange

        case error
        case end
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case id
        case cards
        case meme
        case error
        case players
        case player
        case alreadyCollected
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .initialized:
            self = .initialized(id: try container.decode(String.self, forKey: .id))
        case .successfullyJoined:
            self = .successfullyJoined(player: try container.decode(Player.self, forKey: .player))
        case .playerJoined:
            self = .playerJoined(player: try container.decode(Player.self, forKey: .player))
        case .playerLeft:
            self = .playerLeft(player: try container.decode(Player.self, forKey: .player))
        case .newHost:
            self = .newHost(player: try container.decode(Player.self, forKey: .player))
        case .newCards:
            self = .newCards(try container.decode([Card].self, forKey: .cards))
        case .collecting:
            self = .collecting(try container.decode(StartMeme.self, forKey: .meme))
        case .freeStyle:
            self = .freeStyle(try container.decode(StartMeme.self, forKey: .meme))
        case .update:
            self = .update(try container.decode(UpdateMeme.self, forKey: .meme))
        case .choosing:
            self = .choosing(try container.decode(ChoosingMeme.self, forKey: .meme))
        case .chosen:
            self = .chosen(try container.decode(ChosenMeme.self, forKey: .meme))
        case .judgeChange:
            self = .judgeChange(try container.decode(Player.self, forKey: .player))
        case .error:
            self = .error(try container.decode(GameError.self, forKey: .error))
        case .end:
            self = .end(players: try container.decode([Player].self, forKey: .players))
        }
    }
}
