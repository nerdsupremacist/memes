
import Foundation
import TokamakDOM

struct GameView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        game.gameID.map { id in
            Text("Game Playback: \(id.rawValue)")
        }
    }
}
