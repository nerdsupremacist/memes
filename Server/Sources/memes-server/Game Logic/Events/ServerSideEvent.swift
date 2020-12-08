
import Foundation

enum ServerSideEvent {
    case initialized(id: GameID)
    case successfullyJoined(player: Player)

    case playerJoined(player: Player)
    case playerLeft(player: Player)
    case newHost(player: Player)

    case newCards([Card])

    case collecting(Meme)
    case freeStyle(Meme)
    
    case update(Meme)

    case choosing(Meme)
    case chosen(Meme)
    case judgeChange(Meme, alreadyCollected: Bool)

    case error(GameError)
    case end(players: [Player])
}

extension Meme {

    struct Update: Encodable {
        let submitted: [Player]
    }

    struct Start: Encodable {
        let image: URL
        let judge: Player
    }

    struct Choosing: Encodable {
        let proposals: [String]
    }

    struct Chosen: Encodable {
        let winner: Proposal
        let others: [Proposal]
    }

}

extension ServerSideEvent: Encodable {
    enum Kind: String, Encodable {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .initialized(let id):
            try container.encode(Kind.initialized, forKey: .kind)
            try container.encode(id, forKey: .id)
        case .successfullyJoined(let player):
            try container.encode(Kind.successfullyJoined, forKey: .kind)
            try container.encode(player, forKey: .player)
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
            try container.encode(Meme.Start(image: meme.image, judge: meme.judge), forKey: .meme)
        case .freeStyle(let meme):
            try container.encode(Kind.freeStyle, forKey: .kind)
            try container.encode(Meme.Start(image: meme.image, judge: meme.judge), forKey: .meme)
        case .update(let meme):
            try container.encode(Kind.update, forKey: .kind)
            try container.encode(Meme.Update(submitted: meme.proposedLines.map { $0.player }), forKey: .meme)
        case .choosing(let meme):
            try container.encode(Kind.choosing, forKey: .kind)
            try container.encode(Meme.Choosing(proposals: meme.proposedLines.map { $0.text }), forKey: .meme)
        case .chosen(let meme):
            let winner = meme.winningCard!
            let others = meme.proposedLines.filter { $0.player.id != winner.player.id }
            try container.encode(Kind.chosen, forKey: .kind)
            try container.encode(Meme.Chosen(winner: winner, others: others), forKey: .meme)
        case .judgeChange(let meme, let alreadyCollected):
            try container.encode(Kind.judgeChange, forKey: .kind)
            try container.encode(alreadyCollected, forKey: .alreadyCollected)
            try container.encode(meme.judge, forKey: .player)
        case .error(let error):
            try container.encode(Kind.error, forKey: .kind)
            try container.encode(error, forKey: .error)
        case .end(let players):
            try container.encode(Kind.end, forKey: .kind)
            try container.encode(players, forKey: .players)
        }
    }
}
