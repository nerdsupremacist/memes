
import Foundation
import TokamakDOM

struct GameRootView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        ZStack {
            VStack {
                switch (game.gameID, game.current) {
                case (.some, .some):
                    GameView(game: game)
                case (.none, .none):
                    GameStartView(game: game)
                case (.some, .none):
                    RegisterUserView(game: game)
                default:
                    Text("Loading...")
                }
            }

            if let error = game.error {
                AnyView(
                    VStack {
                        ErrorView(error: error, game: game)
                        Spacer()
                    }
                )
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
        game.register(name: name, emoji: name)
    }

    var body: some View {
        Text("What's your name").font(.title)
        Text("Or your nickname. Whatever...").font(.callout).fontWeight(.regular)

        Spacer().frame(width: 0, height: 4)

        CustomTextField(placeholder: "Name", text: $name) { start() }
    }
}
