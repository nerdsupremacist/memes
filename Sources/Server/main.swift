import Vapor
import Foundation
import Events
import Model

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
        guard let game = game, !game.hasStopped else { return }
        guard let player = player else {
            return game.stop()
        }
        game.getOut(player: player)
    }
}

extension Game {
    private static let lock = Lock()
    private static var games: [GameID : Game] = [:]
    private static let emojis = ["🤓", "✊", "🤴", "🥳", "🤗", "😎", "🥸", "🤪", "🤨", "😂", "🤑"]

    static func handle(event: ClientEvent, for gameRef: inout Game?, from playerRef: inout Player?, using socket: WebSocket) {
        switch (event, gameRef, playerRef) {
        case (.configure(let rounds), .none, _):
            let game = Game(rounds: rounds) { game in
                lock.withLock {
                    games[game.id] = nil
                }
            }
            lock.withLock {
                games[game.id] = game
            }
            gameRef = game
            socket.send(event: .initialized(id: game.id))
            triggerJoin(game: gameRef, player: playerRef)

        case (.join(let id), .none, _):
            guard let game = lock.withLock({ games[id] }) else {
                return socket.send(event: .error(.gameNotFound))
            }
            gameRef = game
            socket.send(event: .initialized(id: id))
            triggerJoin(game: gameRef, player: playerRef)

        case (.register(let name), _, .none):
            let alreadyGiven = gameRef?.emojis ?? []
            var emoji: String
            repeat {
                emoji = emojis.randomElement()!
            } while alreadyGiven.contains(emoji) || alreadyGiven.count == emojis.count

            let player = Player(emoji: emoji, name: name, isHost: false, webSocket: socket)
            playerRef = player
            triggerJoin(game: gameRef, player: playerRef)

        case (_, .some(let game), .some(let player)):
            game.handle(event: event, from: player)

        default:
            socket.send(event: .error(.illegalEvent))
        }
    }

    private static func triggerJoin(game: Game?, player: Player?) {
        guard let game = game, let player = player else { return }
        game.join(player: player)
    }

}

try app.run()
