
import Foundation
import TokamakDOM
import TokamakStaticHTML
import Model

struct ErrorView: View {
    let error: GameError
    let game: Game

    var body: some View {
        DIV(class: "ui icon message") {
            Icon(name: .exclamationCircle)
            DIV(class: "content") {
                DIV(class: "header") {
                    Text("An Error Occurred")
                }
                Paragraph(error.errorDescription(game: game))
            }
        }
    }
}

struct Icon: View {
    enum Name: String {
        case inbox
        case exclamationCircle = "exclamation circle"
    }

    let name: Name

    var body: some View {
        HTML("i", ["class" : "\(name.rawValue) icon"])
    }
}

struct DIV<Content : View>: View {
    let className: String
    let content: Content

    init(class className: String, @ViewBuilder content: () -> Content) {
        self.className = className
        self.content = content()
    }

    var body: some View {
        HTML("div", ["class" : className]) { content }
    }
}

struct Paragraph: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        return HTML("p") { Text(text) }
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
