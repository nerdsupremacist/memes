
import Foundation
import TokamakDOM
import Model

struct GameView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        switch game.state {
        case .initialized:
            WaitingToStartView(game: game)
        case .collecting(let meme):
            CollectingView(game: game, meme: meme)
        case .freestyle(let meme):
            FreestyleView(game: game, meme: meme)
        case .choosing(let meme):
            ChoosingView(game: game, meme: meme)
        case .chosen(let meme, _, _):
            ChosenView(game: game, meme: meme)
        case .done:
            HighscoreListView(game: game)
        }
    }
}
