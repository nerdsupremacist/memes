
import Foundation
import TokamakDOM

struct GameRootView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        switch (game.error, game.gameID, game.current) {
        case (.some(let error), _, _):
            ErrorView(error: error, game: game)
        case (.none, .some, .some):
            GameView(game: game)
        case (.none, .none, .none):
            GameStartView(game: game)
        case (.none, .some, .none):
            RegisterUserView(game: game)
        default:
            Text("Loading...")
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
