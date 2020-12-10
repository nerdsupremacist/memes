import Foundation
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

    @Published
    var error: GameError?

    private let webSocket: WebSocket
    private var cancellables: Set<AnyCancellable> = []

    init(id: GameID? = nil, webSocket: WebSocket) {
        self.webSocket = webSocket
        setup()

        if let id = id {
            send(event: .join(id: id))
            self.gameID = id
        }
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
                    state = .collecting(CollectingMeme(judge: meme.judge, image: meme.image, playerSubmissions: []))
                case .freeStyle:
                    guard case .collecting(let meme) = state else { fatalError("Invalid state change") }
                    state = .freestyle(meme)
                case .update(let update):
                    switch state {
                    case .collecting(var meme), .freestyle(var meme):
                        meme.playerSubmissions = update.submitted
                        state = .collecting(meme)
                    default:
                        fatalError("Invalid state change")
                    }
                case .choosing(let update):
                    switch state {
                    case .collecting(let meme), .freestyle(let meme):
                        state = .choosing(ChoosingMeme(judge: meme.judge, image: meme.image, submissions: update.proposals))
                    default:
                        fatalError("Invalid state change")
                    }
                case .chosen(let update):
                    guard case .choosing(let meme) = state else { fatalError("Invalid state change") }
                    history.append(ChosenMeme(judge: meme.judge, image: meme.image, winner: update.winner, others: update.others))
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
                case .error(let error):
                    self.error = error
                case .end(_):
                    fatalError()
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
        self.gameID = id
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

    func play(card: Card) {
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

    func end() {
        error = nil
        send(event: .end)
    }

    func leave() {
        error = nil
        webSocket.close()
    }
}
