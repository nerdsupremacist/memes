
import Foundation
import TokamakDOM
import Model

struct GameStartView: View {
    @ObservedObject
    var game: Game

    @State
    var isNumber = true

    @State
    var rounds = "5"

    @State
    var name: String = ""

    func start() {
        guard let rounds = Int(rounds) else {
            isNumber = false
            return
        }
        game.configure(rounds: rounds)
    }

    var body: some View {
        VStack {
            Text("Welcome!").font(.title).fontWeight(.heavy)

            Divider().padding(.vertical, 8)
            Divider()
            Divider().padding(.vertical, 8)

            HStack {
                StartANewGameView(game: game)

                Circle().frame(width: 5, height: 5).foregroundColor(.primary)

                JoinAGameView(game: game)
            }
            .padding(.horizontal, 32)
        }
    }
}

struct JoinAGameView: View {
    @ObservedObject
    var game: Game

    @State
    var room = ""

    @State
    var name: String = ""

    func start() {
        game.join(id: GameID(rawValue: room))
        game.register(name: name, emoji: "")
    }

    var body: some View {
        VStack {
            Text("Join a Game").font(.title2)

            TextField("Name",
                      text: $name).padding(16)

            TextField("Room #",
                      text: $room,
                      onEditingChanged: { _ in }) {

                start()
            }
            .padding(.bottom, 16)

            Button("Join") {
                start()
            }
        }
    }
}

struct StartANewGameView: View {
    @ObservedObject
    var game: Game

    @State
    var isNumber = true

    @State
    var rounds = "5"

    @State
    var name: String = ""

    func start() {
        guard let rounds = Int(rounds) else {
            isNumber = false
            return
        }
        game.configure(rounds: rounds)
        game.register(name: name, emoji: "")
    }

    var body: some View {
        VStack {
            Text("Start a Game").font(.title2)

            TextField("Name",
                      text: $name).padding(16)

            if !isNumber {
                Text("Please choose a number")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            TextField("# of Rounds",
                      text: $rounds,
                      onEditingChanged: { _ in }) {

                start()
            }
            .padding(.bottom, 16)

            Button("Create") {
                start()
            }
        }
    }
}
