
import Foundation
import TokamakDOM

struct ChoosingView: View {
    @ObservedObject
    var game: Game
    let meme: Game.ChoosingMeme

    var body: some View {
        GameSplitView {
            Text("Choosing the Winner").font(.title).foregroundColor(.primary)
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
            if let current = game.current, meme.judge.id != current.id {
                HStack {
                    ForEach(meme.submissions, id: \.self) { submission in
                        CardContentView(card: .text(submission), height: height).padding(.horizontal, 8)
                    }
                }
            } else {
                HStack {
                    ForEach(meme.submissions.indices, id: \.self) { index in
                        CustomButton(character: String(index + 1).first!, action: { game.choose(text: meme.submissions[index]) }) {
                            CardContentView(card: .text(meme.submissions[index]), height: height - 46)
                        }
                        .frame(height: height)
                    }
                }
            }
        }
    }
}
