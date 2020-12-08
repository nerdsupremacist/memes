
import Foundation
import Model

public enum ServerSideEvent {
    case initialized(id: GameID)
    case successfullyJoined(player: Player)

    case currentPlayers(players: [Player])
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
    public struct StartMeme: Codable {
        public let image: URL
        public let judge: Player

        public init(image: URL, judge: Player) {
            self.image = image
            self.judge = judge
        }
    }

    public struct UpdateMeme: Codable {
        public let submitted: [Player]

        public init(submitted: [Player]) {
            self.submitted = submitted
        }
    }

    public struct ChoosingMeme: Codable {
        public let proposals: [String]

        public init(proposals: [String]) {
            self.proposals = proposals
        }
    }

    public struct ChosenMeme: Codable {
        public let winner: Proposal
        public let others: [Proposal]

        public init(winner: Proposal, others: [Proposal]) {
            self.winner = winner
            self.others = others
        }
    }
}

extension ServerSideEvent {
    enum Kind: String, Codable {
        case initialized
        case successfullyJoined

        case currentPlayers
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
}

extension ServerSideEvent: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .initialized:
            self = .initialized(id: try container.decode(GameID.self, forKey: .id))
        case .successfullyJoined:
            self = .successfullyJoined(player: try container.decode(Player.self, forKey: .player))
        case .currentPlayers:
            self = .currentPlayers(players: try container.decode([Player].self, forKey: .players))
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

extension ServerSideEvent: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .initialized(let id):
            try container.encode(Kind.initialized, forKey: .kind)
            try container.encode(id, forKey: .id)
        case .successfullyJoined(let player):
            try container.encode(Kind.successfullyJoined, forKey: .kind)
            try container.encode(player, forKey: .player)
        case .currentPlayers(let players):
            try container.encode(Kind.currentPlayers, forKey: .kind)
            try container.encode(players, forKey: .players)
        case .playerJoined(let player):
            try container.encode(Kind.playerJoined, forKey: .kind)
            try container.encode(player, forKey: .player)
        case .playerLeft(let player):
            try container.encode(Kind.playerLeft, forKey: .kind)
            try container.encode(player, forKey: .player)
        case .newHost(let player):
            try container.encode(Kind.newHost, forKey: .kind)
            try container.encode(player, forKey: .player)
        case .newCards(let cards):
            try container.encode(Kind.newCards, forKey: .kind)
            try container.encode(cards, forKey: .cards)
        case .collecting(let meme):
            try container.encode(Kind.collecting, forKey: .kind)
            try container.encode(meme, forKey: .meme)
        case .freeStyle(let meme):
            try container.encode(Kind.freeStyle, forKey: .kind)
            try container.encode(meme, forKey: .meme)
        case .update(let meme):
            try container.encode(Kind.update, forKey: .kind)
            try container.encode(meme, forKey: .meme)
        case .choosing(let meme):
            try container.encode(Kind.choosing, forKey: .kind)
            try container.encode(meme, forKey: .meme)
        case .chosen(let meme):
            try container.encode(Kind.chosen, forKey: .kind)
            try container.encode(meme, forKey: .meme)
        case .judgeChange(let judge):
            try container.encode(Kind.judgeChange, forKey: .kind)
            try container.encode(judge, forKey: .player)
        case .error(let error):
            try container.encode(Kind.error, forKey: .kind)
            try container.encode(error, forKey: .error)
        case .end(let players):
            try container.encode(Kind.end, forKey: .kind)
            try container.encode(players, forKey: .players)
        }
    }
}
