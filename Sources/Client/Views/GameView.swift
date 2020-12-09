
import Foundation
import TokamakDOM

struct GameView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        VStack {
            Text("Players").font(.title).foregroundColor(.primary)
            game.gameID.map { id in
                Text("Room ID: \(id.rawValue)").font(.callout).foregroundColor(.secondary)
            }

            if let player = game.current {
                Spacer().frame(width: 0, height: 4)
                Text("You").font(.title3).foregroundColor(.primary)
                Text(player.name)
            }

            if !game.otherPlayers.isEmpty {
                Spacer().frame(width: 0, height: 4)
                Text("Rest").font(.title3).foregroundColor(.primary)
                ForEach(game.otherPlayers, id: \.id) { player in
                    Text(player.name)
                }
            }

            if game.current?.isHost == true, game.otherPlayers.count > 1 {
                Spacer().frame(width: 0, height: 32)
                ButtonWithNumberKeyPress("Start Game", character: .space, action: { game.start() })
            }
        }
    }
}
