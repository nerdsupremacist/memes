
import Foundation
import TokamakDOM
import Model

struct HighscoreListView: View {
    @ObservedObject
    var game: Game

    var players: [Player] {
        let all = [game.current].compactMap { $0 } + game.otherPlayers
        return all.sorted { lhs, rhs in
            if lhs.winCount > rhs.winCount {
                return true
            }

            if lhs.winCount == rhs.winCount {
                return lhs.name < rhs.name
            }

            return false
        }
    }

    var body: some View {
        VStack {
            Text("That's it!").font(.title).foregroundColor(.primary)
            Text("Here's the final scores").font(.callout).foregroundColor(.secondary)

            Spacer().frame(width: 0, height: 4)
            ForEach(players, id: \.id) { player in
                HStack {
                    Text("\(player.emoji) \(player.name)").font(.callout)
                    Circle().frame(width: 5, height: 5).foregroundColor(.primary).padding(.horizontal, 4)
                    Text("\(player.winCount) Memes").font(.callout)
                }
            }

            if game.current?.isHost == true {
                Spacer().frame(width: 0, height: 32)
                CustomButton("Play again", character: .enter, action: { game.playAgain() })
            }
        }
    }
}
