
import Foundation
import WebSocketKit

class Player {
    let id = UUID()
    let emoji: String
    let name: String

    var isHost: Bool
    var winCount: Int = 0
    var cards: [Card] = []

    private let webSocket: WebSocket

    init(emoji: String, name: String, isHost: Bool, webSocket: WebSocket) {
        self.emoji = emoji
        self.name = name
        self.isHost = isHost
        self.webSocket = webSocket
    }

    func send(event: ServerSideEvent) {
        webSocket.send(event: event)
    }

    func stop() {
        _ = webSocket.close(code: .normalClosure)
    }
}

extension WebSocket {

    func send(event: ServerSideEvent) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(event)
        let string = String(data: data, encoding: .utf8)!
        send(string)
    }

}

extension Player: Encodable {

    struct Body: Encodable {
        let id: UUID
        let emoji: String
        let name: String
        let winCount: Int
        let isHost: Bool

        init(player: Player) {
            self.id = player.id
            self.emoji = player.emoji
            self.name = player.name
            self.winCount = player.winCount
            self.isHost = player.isHost
        }
    }

    func encode(to encoder: Encoder) throws {
        try Body(player: self).encode(to: encoder)
    }

}
