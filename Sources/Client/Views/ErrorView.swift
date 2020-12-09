
import Foundation
import TokamakDOM
import TokamakStaticHTML
import Model

struct ErrorView: View {
    let error: GameError
    let game: Game

    var body: some View {
        VStack {
            Text("An Error Occurred").font(.title).foregroundColor(.primary)
            Text(error.errorDescription(game: game)).font(.callout).foregroundColor(.secondary)

            Spacer().frame(width: 0, height: 32)

            ButtonWithNumberKeyPress("Continue", character: .space) {
                game.error = nil
            }
        }
    }
}

extension GameError {

    func errorDescription(game: Game) -> String {
        switch self {
        case .gameNotFound:
            return "Game Not Found"
        case .onlyTheHostCanStart:
            let host = game.otherPlayers.first { $0.isHost }!
            return "Only the host can start the game (\(host.name))"
        case .onlyTheHostCanEnd:
            let host = game.otherPlayers.first { $0.isHost }!
            return "Only the host can end the game (\(host.name))"
        case .tooManyPlayersDroppedOut:
            return "Too many players dropped out of the game"
        case .gameCanOnlyStartWithAMinimumOfThreePlayers:
            return "Cannot start with less than 3 players (\(game.otherPlayers.count + 1) players)"
        case .judgeCannotPlayACard:
            return "You cannot play a card as a Judge"
        case .onlyJudgeCanChoose:
            let judge: Player
            switch game.state {
            case .choosing(let meme):
                judge = meme.judge
            case .freestyle(let meme):
                judge = meme.judge
            case .collecting(let meme):
                judge = meme.judge
            default:
                fatalError()
            }
            return "Only the judge (\(judge.name)) can choose the winning card"
        case .cannotPlayACardNotInTheHand:
            return "You played a card that wasn't in your hand"
        case .cannotPlayTwiceForTheSameCard:
            return "You cannot play twice for the same Meme"
        case .cardWasNotPlayed:
            return "The card chosen was not played"
        case .gameAlreadyStarted:
            return "Cannot start the game again. It is already running"
        case .illegalEvent:
            return "That operation is not allowed right now"
        case .failedToDecodeEvent:
            return "The server failed to understand the message"
        }
    }

}
