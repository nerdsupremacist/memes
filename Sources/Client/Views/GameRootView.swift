
import Foundation
import TokamakDOM
import Model
import JavaScriptKit

struct GameRootView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        switch (game.state, game.error, game.gameID, game.current) {
        case (.stopped, _, _, _):
            ConnectionLostView(error: game.error)
        case (_, .some(let error), _, _):
            ErrorView(error: error, game: game)
        case (_, .none, .some, .some):
            GameView(game: game)
        case (_, .none, .none, .none):
            GameStartView(game: game)
        case (_, .none, .some, .none):
            RegisterUserView(game: game)
        default:
            Text("Loading...")
        }
    }
}

struct ConnectionLostView: View {
    let error: GameError?

    var body: some View {
        VStack {
            Text("Session Ended").font(.title).foregroundColor(.primary)
            if case .some = error {
                Text("Game was ended because too many users dropped out").font(.callout).foregroundColor(.secondary)
            } else {
                Text("There was a connection problem").font(.callout).foregroundColor(.secondary)
            }

            Spacer().frame(width: 0, height: 32)

            ButtonWithNumberKeyPress("Go back to menu", character: .enter) {
                let location = JSObject.global.window.object!["location"].object!
                _ = location.reload!()
            }
        }
    }
}

struct RegisterUserView: View {
    let game: Game

    @State
    private var name: String = ""

    func start() {
        guard !name.isEmpty else { return }
        game.register(name: name)
    }

    var body: some View {
        VStack {
            Text("What's your name").font(.title)
            Text("Or your nickname. Whatever...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 4)

            CustomTextField(placeholder: "Name", text: $name) { start() }
        }
    }
}
