
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
