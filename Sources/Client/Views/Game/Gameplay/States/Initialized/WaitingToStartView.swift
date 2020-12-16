
import Foundation
import TokamakDOM

struct WaitingToStartView: View {
    @ObservedObject
    var game: Game

    var body: some View {
        VStack {
            Text("Players").font(.title).foregroundColor(.primary)
            game.gameID.map { id in
                Text("Room ID: \(id.rawValue)").font(.callout).foregroundColor(.secondary)
            }

            VStack {
                if let player = game.current {
                    Spacer().frame(width: 0, height: 4)
                    Text("You").font(.title3).foregroundColor(.primary)
                    Text("\(player.emoji) \(player.name)").font(.callout)
                }

                if !game.otherPlayers.isEmpty {
                    Spacer().frame(width: 0, height: 4)
                    Text("Rest").font(.title3).foregroundColor(.primary)
                    ForEach(game.otherPlayers, id: \.id) { player in
                        Text("\(player.emoji) \(player.name)").font(.callout)
                    }
                } else {
                    EmptyView()
                }
            }

            Spacer().frame(width: 0, height: 32)

            HStack {
                InviteUserButton(game: game)

                if game.current?.isHost == true, game.otherPlayers.count > 1 {
                    Spacer().frame(width: 16, height: 0)
                    CustomButton("Start Game", character: .enter, action: { game.start() })
                }
            }
        }
    }
}
