
import Foundation
import TokamakDOM

struct ChosenView: View {
    @ObservedObject
    var game: Game
    let meme: Game.ChosenMeme

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer().frame(width: 0, height: 64)

                Text("The judge has spoken!").font(.title).foregroundColor(.primary)
                if meme.judge.id == game.current?.id {
                    Text("I mean, you have spoken...").font(.callout).foregroundColor(.secondary)
                } else {
                    HStack {
                        Text("Judge: ").font(.callout).foregroundColor(.secondary)
                        Text("\(meme.judge.emoji) \(meme.judge.name)").font(.callout).foregroundColor(.secondary)
                    }
                }

                Spacer()

                HStack {
                    VStack {
                        Text("Meme:").font(.title3).foregroundColor(.primary)
                        Spacer().frame(width: 0, height: 4)
                        Image(meme.image.absoluteString).frame(height: proxy.size.height / 2.5)
                    }

                    Spacer().frame(width: 16, height: 0)

                    VStack {
                        Text("Winner:").font(.title3).foregroundColor(.primary)
                        Spacer().frame(width: 0, height: 8)
                        CardContentView(card: .text(meme.winner.text), height: proxy.size.height / 3)
                        Spacer().frame(width: 0, height: 8)
                        Text("\(meme.winner.player.emoji) \(meme.winner.player.name)").font(.callout)
                        Text("\(meme.winner.player.winCount) Points").font(.callout)
                    }
                }

                Spacer()

                CustomButton("Next", character: .enter) { game.continue() }

                Spacer().frame(width: 0, height: 64)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}
