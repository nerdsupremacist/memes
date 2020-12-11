
import Foundation
import TokamakDOM
import TokamakStaticHTML
import Model

struct ErrorView: View {
    let error: GameError
    let session: Session

    var body: some View {
        VStack {
            Text("An Error Occurred").font(.title).foregroundColor(.primary)
            Text(error.errorDescription()).font(.callout).foregroundColor(.secondary)

            Spacer().frame(width: 0, height: 32)

            ButtonWithNumberKeyPress("Continue", character: .space) {
                session.clearError()
            }
        }
    }
}

extension GameError {

    func errorDescription() -> String {
        switch self {
        case .gameNotFound:
            return "Game Not Found"
        case .onlyTheHostCanStart:
            return "Only the host can start the game"
        case .onlyTheHostCanEnd:
            return "Only the host can end the game"
        case .tooManyPlayersDroppedOut:
            return "Too many players dropped out of the game"
        case .gameCanOnlyStartWithAMinimumOfThreePlayers:
            return "Cannot start with less than 3 players"
        case .judgeCannotPlayACard:
            return "You cannot play a card as a Judge"
        case .onlyJudgeCanChoose:
            return "Only the judge can choose the winning card"
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
