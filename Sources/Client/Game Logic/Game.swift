import TokamakDOM
import OpenCombine
import Model
import Events

typealias ObservableObject = TokamakDOM.ObservableObject
typealias Published = TokamakDOM.Published

class Game: ObservableObject {
    enum State {
        case initialized
        case collecting(CollectingMeme)
        case freestyle(CollectingMeme)
        case choosing(ChoosingMeme)
        case ended
    }
    
    struct CollectingMeme {
        var judge: Player
        var image: String?
        var playerSubmissions: [Player]
    }

    struct ChoosingMeme {
        var judge: Player
        var image: String?
        var submissions: [String]
    }

    struct ChosenMeme {
        var judge: Player
        var image: String?
        var winner: Proposal
        var others: [Proposal]
    }

    @Published
    private(set) var gameID: GameID?

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
            .sink { value in
                switch value {
                case .initialized(let id):
                    self.gameID = id
                case .successfullyJoined(let player):
                    self.current = player
                case .currentPlayers(let players):
                    self.otherPlayers.append(contentsOf: players)
                case .playerJoined(let player):
                    self.otherPlayers.append(player)
                case .playerLeft(let player):
                    self.otherPlayers.removeAll { $0.id == player.id }
                case .newHost(_):
                    fatalError()
                case .newCards(let cards):
                    self.cards.append(contentsOf: cards)
                case .collecting(_):
                    fatalError()
                case .freeStyle(_):
                    fatalError()
                case .update(_):
                    fatalError()
                case .choosing(_):
                    fatalError()
                case .chosen(_):
                    fatalError()
                case .judgeChange(_):
                    fatalError()
                case .error(_):
                    fatalError()
                case .end(_):
                    fatalError()
                }
            }
            .store(in: &cancellables)
    }

}

extension Game {
    func configure(rounds: Int) {
        send(event: .configure(rounds: rounds))
    }

    func register(name: String, emoji: String) {
        send(event: .register(name: name, emoji: emoji))
    }

    func start() {
        send(event: .start)
    }

    func play(card: Card) {
        send(event: .play(card))
    }

    func freestyle(text: String) {
        send(event: .freestyle(text))
    }

    func choose(text: String) {
        send(event: .choose(text))
    }

    func end() {
        send(event: .end)
    }

    func leave() {
        webSocket.close()
    }
}
