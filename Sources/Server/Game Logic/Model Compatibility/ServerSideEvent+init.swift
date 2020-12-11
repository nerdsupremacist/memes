
import Foundation
import Events
import Model

extension ServerSideEvent {

    static func successfullyJoined(player: Player) -> ServerSideEvent {
        return .successfullyJoined(player: player.model())
    }

    static func currentPlayers(players: [Player]) -> ServerSideEvent {
        return .currentPlayers(players: players.map { $0.model() })
    }

    static func playerJoined(player: Player) -> ServerSideEvent {
        return .playerJoined(player: player.model())
    }

    static func playerLeft(player: Player) -> ServerSideEvent {
        return .playerLeft(player: player.model())
    }

    static func newHost(player: Player) -> ServerSideEvent {
        return .newHost(player: player.model())
    }

    static func judgeChange(player: Player) -> ServerSideEvent {
        return .judgeChange(player.model())
    }

    static func collecting(_ meme: Meme) -> ServerSideEvent {
        return .collecting(StartMeme(image: meme.image, judge: meme.judge.model()))
    }

    static func freestyle(_ meme: Meme) -> ServerSideEvent {
        return .freeStyle(StartMeme(image: meme.image, judge: meme.judge.model()))
    }

    static func update(_ meme: Meme) -> ServerSideEvent {
        return .update(UpdateMeme(submitted: meme.proposedLines.map { $0.player.model() }))
    }

    static func choosing(_ meme: Meme) -> ServerSideEvent {
        return .choosing(ChoosingMeme(proposals: meme.proposedLines.map { $0.text }.shuffled()))
    }

    static func chosen(_ meme: Meme) -> ServerSideEvent {
        let winner = meme.winningCard!
        let others = meme.proposedLines.filter { $0.player.id != winner.player.id }
        return .chosen(ChosenMeme(winner: winner.model(), others: others.map { $0.model() }))
    }

    static func end(players: [Player]) -> ServerSideEvent {
        return .end(players: players.map { $0.model() })
    }
}
