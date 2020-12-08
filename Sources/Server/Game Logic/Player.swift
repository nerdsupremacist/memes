
import Foundation
import WebSocketKit
import Model
import Events

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
