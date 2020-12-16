
import Foundation
import TokamakDOM

struct CollectingView: View {
    @ObservedObject
    var game: Game
    let meme: Game.CollectingMeme

    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 64)

            Text("Collecting Submissions").font(.title).foregroundColor(.primary)
            if meme.judge.id == game.current?.id {
                Text("You are judging").font(.callout).foregroundColor(.secondary)
            } else {
                HStack {
                    Text("Judge: ").font(.callout).foregroundColor(.secondary)
                    Text("\(meme.judge.emoji) \(meme.judge.name)").font(.callout).foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(meme.image.absoluteString).frame(height: 500)

            Spacer()

            if let current = game.current, meme.judge.id != current.id && !meme.playerSubmissions.map({ $0.id }).contains(current.id) {
                HStack {
                    ForEach(game.cards.indices) { index in
                        CardView(game: game, card: game.cards[index], index: index)
                    }
                }
            } else {
                if !meme.playerSubmissions.isEmpty {
                    VStack {
                        Text("Submitted:").font(.title3).foregroundColor(.primary)
                        ForEach(meme.playerSubmissions, id: \.id) { player in
                            Text("\(player.emoji) \(player.name)").font(.callout)
                        }
                        Spacer()
                    }
                    .frame(height: 330)
                } else {
                    EmptyView().frame(height: 330)
                }
            }

            Spacer().frame(width: 0, height: 64)
        }
    }
}
