import Foundation
import TokamakDOM
import OpenCombine
import JavaScriptKit

struct Memes: App {
    let game = Game(webSocket: WebSocket(url: URL(string: "ws://localhost:3000/game")!))

    var body: some Scene {
        WindowGroup("Memes") {
            GameScreen(game: game)
        }
    }
}

struct GameScreen: View {
    @ObservedObject
    var game: Game

    var body: some View {
        if game.gameID == nil {
            ConfigureGameScreen(game: game)
        } else if game.current == nil {
            RegisterPlayerScreen(game: game)
        } else {
            GamePlaybackScreen(game: game)
        }
    }
}

struct ConfigureGameScreen: View {
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
            Text("Start a Game!").font(.title2)

            TextField("Name",
                      text: $name).padding(16)

            if !isNumber {
                Text("Please choose a number").font(.caption)
            }

            TextField("# of Rounds",
                      text: $rounds,
                      onEditingChanged: { _ in }) {

                start()
            }
            .padding(16)

            Button("Create Game") {
                start()
            }
        }
    }
}

struct RegisterPlayerScreen: View {
    @ObservedObject
    var game: Game

    @State
    var name: String = ""

    var body: some View {
        VStack {
            Text("Who are you").font(.title2)

            Button("Start") {

            }
        }
    }
}

struct GamePlaybackScreen: View {
    @ObservedObject
    var game: Game

    var body: some View {
        Text("Game Playback")
    }
}

struct Counter: View {
    @State var count: Int
    let limit: Int

    var body: some View {
        if count < limit {
            VStack {
                Button("Increment") { count += 1 }
                Text("\(count)")
            }
            .onAppear { print("Counter.VStack onAppear") }
            .onDisappear { print("Counter.VStack onDisappear") }
        } else {
            VStack { Text("Limit exceeded") }
        }
    }
}


// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
Memes.main()
