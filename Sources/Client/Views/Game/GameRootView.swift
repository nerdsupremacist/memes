
import Foundation
import TokamakDOM
import Model

struct GameRootView: View {
    let session: Session

    @ObservedObject
    var game: Game

    var body: some View {
        switch (game.gameID, game.current) {
        case (.some, .none):
            RegisterUserView(game: game)
        case (.some, .some):
            GameView(game: game)
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
