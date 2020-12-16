
import Foundation
import TokamakDOM

struct CollectingView: View {
    @ObservedObject
    var game: Game
    let meme: Game.CollectingMeme

    var body: some View {
        GameSplitView {
                Text("Collecting Submissions").font(.title).foregroundColor(.primary)
                if meme.judge.id == game.current?.id {
                    Text("You are judging").font(.callout).foregroundColor(.secondary)
                } else {
                    HStack {
                        Text("Judge: ").font(.callout).foregroundColor(.secondary)
                        Text("\(meme.judge.emoji) \(meme.judge.name)").font(.callout).foregroundColor(.secondary)
                    }
                }
        } center: { height in
            Image(meme.image.absoluteString).frame(height: height)
        } bottom: { height in
            if let current = game.current, meme.judge.id != current.id && !meme.playerSubmissions.map({ $0.id }).contains(current.id) {
                VStack {
                    Spacer().frame(width: 0, height: 4)
                    HStack {
                        ForEach(game.cards.indices) { index in
                            CardView(game: game, card: game.cards[index], index: index, height: height - 8)
                        }
                    }
                    Spacer().frame(width: 0, height: 4)
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
                    .frame(height: height)

                } else {
                    EmptyView()
                        .frame(height: height)
                }
            }
        }
    }
}
