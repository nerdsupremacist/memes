
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
        case .choosing(let meme):
            ChoosingView(game: game, meme: meme)
        default:
            Text("State not implemented")
        }
    }
}

struct WaitingToStartView: View {
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
                Text("\(player.emoji) \(player.name)").font(.callout)
            }

            if !game.otherPlayers.isEmpty {
                Spacer().frame(width: 0, height: 4)
                Text("Rest").font(.title3).foregroundColor(.primary)
                ForEach(game.otherPlayers, id: \.id) { player in
                    Text("\(player.emoji) \(player.name)").font(.callout)
                }
            }

            if game.current?.isHost == true, game.otherPlayers.count > 1 {
                Spacer().frame(width: 0, height: 32)
                ButtonWithNumberKeyPress("Start Game", character: .enter, action: { game.start() })
            }
        }
    }
}

struct ChoosingView: View {
    @ObservedObject
    var game: Game
    let meme: Game.ChoosingMeme

    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 64)

            Text("Choosing the Winner").font(.title).foregroundColor(.primary)
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

            if let current = game.current, meme.judge.id != current.id {
                HStack {
                    ForEach(meme.submissions, id: \.self) { submission in
                        CardContentView(card: .text(submission))
                    }
                }
            } else {
                HStack {
                    ForEach(meme.submissions.indices, id: \.self) { index in
                        ButtonWithNumberKeyPress(character: String(index + 1).first!, action: { game.choose(text: meme.submissions[index]) }) {
                            CardContentView(card: .text(meme.submissions[index]))
                        }
                    }
                }
            }

            Spacer().frame(width: 0, height: 64)
        }
    }
}

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
                    }
                } else {
                    EmptyView()
                }
            }

            Spacer().frame(width: 0, height: 64)
        }
    }
}

struct CardView: View {
    let game: Game
    let card: Card
    let index: Int

    @Environment(\.colorScheme)
    var colorScheme

    var effectiveColorScheme: ColorScheme {
        guard isFreeStyle else { return colorScheme }
        switch colorScheme {
        case .light:
            return .dark
        case .dark:
            return .light
        }
    }

    var isFreeStyle: Bool {
        guard case .freestyle = card else { return false }
        return true
    }

    var text: String {
        switch card {
        case .text(let text):
            return text
        case .freestyle:
            return "Freestyle!"
        }
    }

    var body: some View {
        ButtonWithNumberKeyPress(character: String(index + 1).first!, action: { game.play(card: card) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(effectiveColorScheme == .light ? Color.black : Color.white)

                Text(text).foregroundColor(effectiveColorScheme == .light ? Color.white : Color.black).font(.body).frame(width: 180)
            }
            .frame(width: 100, height: 200)
        }
    }
}

struct CardContentView: View {
    let card: Card

    @Environment(\.colorScheme)
    var colorScheme

    var effectiveColorScheme: ColorScheme {
        guard isFreeStyle else { return colorScheme }
        switch colorScheme {
        case .light:
            return .dark
        case .dark:
            return .light
        }
    }

    var isFreeStyle: Bool {
        guard case .freestyle = card else { return false }
        return true
    }

    var text: String {
        switch card {
        case .text(let text):
            return text
        case .freestyle:
            return "Freestyle!"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(effectiveColorScheme == .light ? Color.black : Color.white)

            Text(text).foregroundColor(effectiveColorScheme == .light ? Color.white : Color.black).font(.body).frame(width: 180)
        }
        .frame(width: 100, height: 200)
    }
}
