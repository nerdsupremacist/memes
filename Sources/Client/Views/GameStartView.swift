
import Foundation
import TokamakDOM
import Model

struct GameStartView: View {
    @ObservedObject
    var game: Game

    @State
    private var kind: Kind? = nil

    enum Kind {
        case start
        case join
    }

    var body: some View {
        switch kind {
        case .none:
            ChooseKindView(kind: $kind)
        case .some(.start):
            StartANewGameView(game: game)
        case .some(.join):
            JoinAGameView(game: game)
        }
    }
}

private struct ChooseKindView: View {
    @Binding
    var kind: GameStartView.Kind?

    var body: some View {
        VStack {
            Text("Welcome!").font(.title).fontWeight(.heavy)
            Text("This is a game where you pick the captions for memes.").font(.callout).fontWeight(.regular)
            Text("One person get's to decide which is the funniest.").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 16)

            Text("Let's see who the funniest/most horrible person in your group is...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 4)

            HStack {
                ButtonWithNumberKeyPress("Start a Game", character: "1") {
                    kind = .start
                }

                ButtonWithNumberKeyPress("Join a Game", character: "2") {
                    kind = .join
                }
            }
        }
    }
}

struct JoinAGameView: View {
    var game: Game

    @State
    private var room = ""

    func start() {
        game.join(id: GameID(rawValue: room))
    }

    var body: some View {
        VStack {
            Text("Enter the Room #").font(.title)
            Text("The person hosting the game should've given you a code by now...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 4)

            CustomTextField(placeholder: "Room #", text: $room) { start() }
        }
    }
}

struct NumberOfRoundsButton: View {
    let number: Int
    let game: Game

    var body: some View {
        ButtonWithNumberKeyPress(character: String(number % 10).first!, action: { game.configure(rounds: number) }) {
            NumberOfRoundsContent(number: number)
        }
    }
}

struct NumberOfRoundsContent: View {
    @Environment(\.colorScheme)
    var colorScheme
    let number: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(colorScheme == .light ? Color.black : Color.white)
                .frame(width: 100, height: 100)

            Text(String(number)).foregroundColor(colorScheme == .light ? Color.white : Color.black).font(.title3)
        }
        .frame(width: 100, height: 100)
    }
}

struct StartANewGameView: View {
    let game: Game

    var body: some View {
        VStack {
            Text("How many rounds").font(.title)

            Text("In every round each player will have a turn judging everyone else's submissions.").font(.callout).fontWeight(.regular)
            Text("If you don't get it, don't worry. You'll learn by playing...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 4)

            HStack {
                ForEach(0..<10) { number in
                    NumberOfRoundsButton(number: number + 1, game: game)
                }
            }
        }
    }
}
