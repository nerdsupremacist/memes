
import Foundation
import TokamakDOM
import Model
import JavaScriptKit

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

struct InviteUserButton: View {
    let game: Game

    @State
    var isCopying = false

    @State
    var timer: JSTimer?

    func copy() {
        guard !isCopying else { return }

        let window = JSObject.global.window.object!
        guard var components = window["location"].object?["href"].string.flatMap(URLComponents.init(string:)) else { return }
        components.queryItems = game.gameID.map { [URLQueryItem(name: "id", value: $0.rawValue)] }

        if let string = components.string {
            let clipboard = JSObject.global.navigator.object!["clipboard"].object!
            _ = clipboard.writeText!(string)
        }

        isCopying = true

        timer = JSTimer(millisecondsDelay: 1_000) {
            isCopying = false
        }
    }

    var body: some View {
        ButtonWithNumberKeyPress(isCopying ? "Link Copied!" : "Invite Friends", character: "C") { copy() }
    }
}

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
                ButtonWithNumberKeyPress("Play again", character: .enter, action: { game.playAgain() })
            }
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
                    ButtonWithNumberKeyPress("Start Game", character: .enter, action: { game.start() })
                }
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
                        CardContentView(card: .text(submission)).padding(.horizontal, 8)
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

struct FreestyleView: View {
    @ObservedObject
    var game: Game
    let meme: Game.CollectingMeme

    @State
    var text: String = ""

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
                VStack {
                    CustomTextField(placeholder: "Your submission", text: $text) { game.freestyle(text: text) }
                }
                .frame(height: 330)
            } else {
                if !meme.playerSubmissions.isEmpty {
                    VStack {
                        Text("Submitted:").font(.title3).foregroundColor(.primary)
                        ForEach(meme.playerSubmissions, id: \.id) { player in
                            Text("\(player.emoji) \(player.name)").font(.callout)
                        }
                    }
                    .frame(height: 330)
                } else {
                    EmptyView()
                        .frame(height: 330)
                }
            }

            Spacer().frame(width: 0, height: 64)
        }
    }
}

struct ChosenView: View {
    @ObservedObject
    var game: Game
    let meme: Game.ChosenMeme

    var body: some View {
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
                    Image(meme.image.absoluteString).frame(height: 360)
                }

                Spacer().frame(width: 16, height: 0)

                VStack {
                    Text("Winner:").font(.title3).foregroundColor(.primary)
                    Spacer().frame(width: 0, height: 8)
                    CardContentView(card: .text(meme.winner.text))
                    Spacer().frame(width: 0, height: 8)
                    Text("\(meme.winner.player.emoji) \(meme.winner.player.name)").font(.callout)
                    Text("\(meme.winner.player.winCount) Points").font(.callout)
                }
            }

            Spacer()


            ButtonWithNumberKeyPress("Next", character: .enter) { game.continue() }

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
            CardContentView(card: card)
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
            RoundedRectangle(cornerRadius: 21)
                .fill(effectiveColorScheme == .light ? Color.white : Color.black)
                .frame(width: 200, height: 300)

            RoundedRectangle(cornerRadius: 20)
                .fill(effectiveColorScheme == .light ? Color.black : Color.white)
                .frame(width: 198, height: 298)

            VStack {
                Text(text).foregroundColor(effectiveColorScheme == .light ? Color.white : Color.black).font(.body).frame(width: 200-8)
            }
        }
        .frame(width: 200, height: 300)
    }
}
