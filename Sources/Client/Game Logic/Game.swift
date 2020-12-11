import Foundation
import JavaScriptKit
import Model
import Events
import CombineShim

class Game: ObservableObject {
    enum State {
        case initialized
        case collecting(CollectingMeme)
        case freestyle(CollectingMeme)
        case choosing(ChoosingMeme)
        case chosen(ChosenMeme, next: CollectingMeme?, atEnd: Bool)
        case done
    }
    
    struct CollectingMeme {
        var judge: Player
        var image: URL
        var playerSubmissions: [Player]
    }

    struct ChoosingMeme {
        var judge: Player
        var image: URL
        var submissions: [String]
    }

    struct ChosenMeme {
        var judge: Player
        var image: URL
        var winner: Proposal
        var others: [Proposal]
    }

    @Published
    private(set) var gameID: GameID? {
        didSet {
            let window = JSObject.global.window.object!
            guard var components = window["location"].object?["href"].string.flatMap(URLComponents.init(string:)) else { return }
            let withoutID = components.queryItems?.filter { $0.name != "id" } ?? []
            let idParam = gameID.map { [URLQueryItem(name: "id", value: $0.rawValue)] } ?? []
            components.queryItems = idParam + withoutID
            if components.query!.isEmpty {
                components.queryItems = nil
            }
            if let string = components.string {
                _ = window["history"].object!.replaceState?([:], "", string)
            }
        }
    }

    @Published
    private(set) var state: State = .initialized

    @Published
    private(set) var current: Player?

    @Published
    private(set) var otherPlayers: [Player] = []

    @Published
    private(set) var cards: [Card] = []

    @Published
    private(set) var history: [ChosenMeme] = []

    @Published
    var error: GameError?

    private let webSocket: WebSocket
    private var cancellables: Set<AnyCancellable> = []

    init(webSocket: WebSocket) {
        self.webSocket = webSocket
        setup()
    }

    private func send(event: ClientEvent) {
        webSocket.send(event)
    }
}

extension Game {

    private func setup() {
        cancellables = []
        webSocket
            .messages(type: ServerSideEvent.self)
            .sink { [unowned self] event in
                #if DEBUG
                print("Event received: \(event)")
                #endif

                switch event {
                case .initialized(let id):
                    self.gameID = id
                case .successfullyJoined(let player):
                    self.current = player
                case .playAgain:
                    self.error = nil
                    self.current = self.current.map { Player(id: $0.id, emoji: $0.emoji, name: $0.name, winCount: 0, isHost: $0.isHost) }
                    self.otherPlayers = self.otherPlayers.map { Player(id: $0.id, emoji: $0.emoji, name: $0.name, winCount: 0, isHost: $0.isHost) }
                    self.history = []
                    self.cards = []
                    self.state = .initialized
                case .currentPlayers(let players):
                    self.otherPlayers.append(contentsOf: players)
                case .playerJoined(let player):
                    self.otherPlayers.append(player)
                case .playerLeft(let player):
                    self.otherPlayers.removeAll { $0.id == player.id }
                case .newHost(let player):
                    if player.id == current?.id {
                        current?.isHost = true
                    }
                    // TODO: Mark another player as host (not important yet)
                case .newCards(let cards):
                    self.cards.append(contentsOf: cards)
                case .collecting(let meme):
                    let next = CollectingMeme(judge: meme.judge, image: meme.image, playerSubmissions: [])
                    if case .chosen(let chosen, _, false) = state {
                        state = .chosen(chosen, next: next, atEnd: false)
                    } else {
                        state = .collecting(next)
                    }
                case .freeStyle:
                    guard case .collecting(let meme) = state else { fatalError("Invalid state change") }
                    state = .freestyle(meme)
                case .update(let update):
                    switch state {
                    case .collecting(var meme):
                        meme.playerSubmissions = update.submitted
                        state = .collecting(meme)
                    case .freestyle(var meme):
                        meme.playerSubmissions = update.submitted
                        state = .freestyle(meme)
                    case .chosen(let chosen, .some(var meme), false):
                        meme.playerSubmissions = update.submitted
                        state = .chosen(chosen, next: meme, atEnd: false)
                    default:
                        fatalError("Invalid state change")
                    }
                case .choosing(let update):
                    switch state {
                    case .collecting(let meme), .freestyle(let meme), .chosen(_, .some(let meme), false):
                        state = .choosing(ChoosingMeme(judge: meme.judge, image: meme.image, submissions: update.proposals))
                    default:
                        fatalError("Invalid state change")
                    }
                case .chosen(let update):
                    guard case .choosing(let meme) = state else { fatalError("Invalid state change") }
                    let chosen = ChosenMeme(judge: meme.judge, image: meme.image, winner: update.winner, others: update.others)
                    state = .chosen(chosen, next: nil, atEnd: false)
                    history.append(chosen)
                case .judgeChange(let judge):
                    switch state {
                    case .collecting(let meme):
                        state = .collecting(CollectingMeme(judge: judge, image: meme.image, playerSubmissions: meme.playerSubmissions))
                    case .freestyle(let meme):
                        state = .freestyle(CollectingMeme(judge: judge, image: meme.image, playerSubmissions: meme.playerSubmissions))
                    case .choosing(let meme):
                        state = .choosing(ChoosingMeme(judge: judge, image: meme.image, submissions: meme.submissions))
                    default:
                        fatalError("Invalid state change")
                    }
                case .error(.gameNotFound):
                    self.gameID = nil
                    self.error = .gameNotFound
                    self.leave()
                case .error(let error):
                    self.error = error
                case .end(let players):
                    self.otherPlayers = players.filter { $0.id != current?.id }
                    self.current = players.first { $0.id == current?.id }
                    if case .chosen(let meme, .none, _) = state {
                        state = .chosen(meme, next: nil, atEnd: true)
                    } else {
                        state = .done
                    }
                }
            }
            .store(in: &cancellables)
    }

}

extension Game {
    func configure(rounds: Int) {
        error = nil
        send(event: .configure(rounds: rounds))
    }

    func join(id: GameID) {
        error = nil
        send(event: .join(id: id))
    }

    func register(name: String) {
        error = nil
        send(event: .register(name: name))
    }

    func start() {
        error = nil
        send(event: .start)
    }

    func `continue`() {
        switch state {
        case .chosen(_, .some(let next), false):
            state = .collecting(next)
        case .chosen(_, .none, true):
            state = .done
        default:
            break
        }
    }

    func play(card: Card) {
        cards.removeFirst(card)
        error = nil
        send(event: .play(card))
    }

    func freestyle(text: String) {
        error = nil
        send(event: .freestyle(text))
    }

    func choose(text: String) {
        error = nil
        send(event: .choose(text))
    }

    func playAgain() {
        error = nil
        send(event: .playAgain)
    }

    func stop() {
        error = nil
        send(event: .stop)
    }

    func leave() {
        webSocket.close()
    }
}
