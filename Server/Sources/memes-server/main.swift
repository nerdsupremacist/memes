import Vapor

let app = Application(try .detect())

app.webSocket("game") { request, socket in
    var game: Game?
    var player: Player?

    socket.onText { _, text in
        guard let data = text.data(using: .utf8),
              let event = try? JSONDecoder().decode(ClientEvent.self, from: data) else {

            return socket.send(event: .error(.failedToDecodeEvent))
        }

        Game.handle(event: event, for: &game, from: &player, using: socket)
    }

    socket.onClose.whenComplete { _ in
        guard let game = game, !game.hasEnded else { return }
        guard let player = player else {
            return game.end()
        }
        game.getOut(player: player)
    }
}

app.webSocket("game", .parameter("id")) { request, socket in
    guard let parameter = request.parameters.get("id"),
          let game = Game.game(with: GameID(rawValue: parameter)) else {

        socket.send(event: .error(.gameNotFound))
        _ = socket.close(code: .normalClosure)
        return
    }

    var player: Player?
    socket.onText { _, text in
        guard let data = text.data(using: .utf8),
              let event = try? JSONDecoder().decode(ClientEvent.self, from: data) else {

            return socket.send(event: .error(.failedToDecodeEvent))
        }

        game.handle(event: event, from: &player, using: socket)
    }
    
    socket.onClose.whenComplete { _ in
        guard let player = player, !game.hasEnded else { return }
        game.getOut(player: player)
    }
}

extension Game {

    private static let lock = Lock()
    private static var games: [GameID : Game] = [:]

    static func game(with id: GameID) -> Game? {
        return lock.withLock { games[id] }
    }

    static func handle(event: ClientEvent, for gameRef: inout Game?, from playerRef: inout Player?, using socket: WebSocket) {
        guard let game = gameRef else {
            if case .configure(let rounds) = event {
                let newGame = Game(rounds: rounds) { game in
                    lock.withLock {
                        games[game.id] = nil
                    }
                }
                lock.withLock {
                    games[newGame.id] = newGame
                }
                gameRef = newGame
                socket.send(event: .initialized(id: newGame.id))
            } else {
                socket.send(event: .error(.illegalEvent))
            }

            return
        }

        game.handle(event: event, from: &playerRef, using: socket)
    }

    func handle(event: ClientEvent, from playerRef: inout Player?, using socket: WebSocket) {
        guard let player = playerRef else {
            if case .register(let name, let emoji) = event {
                let newPlayer = Player(emoji: emoji, name: name, isHost: false, webSocket: socket)
                join(player: newPlayer)
                playerRef = newPlayer
            } else {
                socket.send(event: .error(.illegalEvent))
            }

            return
        }

        handle(event: event, from: player)
    }

}

try app.run()
