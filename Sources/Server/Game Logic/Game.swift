
import Foundation
import Events
import Model

class Game {
    enum State {
        case initialized
        case collecting(Meme)
        case freestyle(Meme)
        case choosing(Meme)
        case ended
    }

    let id = GameID()
    
    private var host: Player?
    private let rounds: Int
    private let deck: Deck
    private let gameEndCompletion: (Game) -> Void

    private var players: [Player]
    private var history: [Meme] = []

    private var judgeIndex: Int = 0
    private let lock = Lock()

    private var state: State = .initialized {
        didSet {
            switch (oldValue, state) {
            case (.initialized, .collecting(let meme)):
                send(event: .collecting(meme))

            case (.choosing(let prev), .collecting(let next)):
                send(event: .chosen(prev))
                send(event: .collecting(next))

            case (.collecting, .freestyle(let meme)):
                send(event: .freestyle(meme))

            case (.freestyle, .choosing(let meme)):
                send(event: .choosing(meme))

            case (.collecting, .choosing(let meme)):
                send(event: .choosing(meme))

            case (.collecting(let meme), .ended):
                if meme.winningCard != nil {
                    send(event: .chosen(meme))
                }
                fallthrough

            case (_, .ended):
                send(event: .end(players: players))
                gameEndCompletion(self)

            default:
                fatalError("Invalid State Change")
            }
        }
    }

    var hasStarted: Bool {
        if case .initialized = state {
            return false
        } else {
            return true
        }
    }

    var hasEnded: Bool {
        if case .ended = state {
            return true
        } else {
            return false
        }
    }

    init(rounds: Int, deck: Deck = StandardDeck.basic, gameEndCompletion: @escaping (Game) -> Void) {
        self.rounds = rounds
        self.deck = deck
        self.gameEndCompletion = gameEndCompletion
        self.players = []
    }

    func join(player: Player) {
        lock.withLock {
            guard case .initialized = state else {
                player.send(event: .error(.gameAlreadyStarted))
                player.stop()
                return
            }
            if host == nil {
                host = player
                player.isHost = true
            }
            send(event: .playerJoined(player: player))
            if !players.isEmpty {
                player.send(event: .currentPlayers(players: players))
            }
            players.append(player)
            player.send(event: .successfullyJoined(player: player))
        }
    }

    func getOut(player: Player) {
        lock.withLock {
            guard players.contains(where: { $0.id == player.id }) else { return }
            players.removeAll { $0.id == player.id }
            if players.isEmpty {
                end()
                return
            }

            if hasStarted, players.count < 3 {
                send(event: .error(.tooManyPlayersDroppedOut))
                end()
                return
            }

            if player.isHost, let newHost = players.first {
                newHost.isHost = true
                send(event: .newHost(player: newHost))
            }

            if hasStarted {
                judgeIndex = judgeIndex % players.count
                switch state {
                case .choosing(let meme), .collecting(let meme):
                    if meme.judge.id == player.id {
                        meme.judge = players[judgeIndex]
                        meme.proposedLines.removeAll { $0.player.id == meme.judge.id }
                        send(event: .judgeChange(player: meme.judge))
                    }
                default:
                    break
                }
            }

            send(event: .playerLeft(player: player))
        }
    }

    func handle(event: ClientEvent, from player: Player) {
        lock.withLock {
            switch (state, event) {
            case (.initialized, .start):
                start(as: player)

            case (.collecting(let meme), .play(let card)):
                play(card: card, for: meme, as: player)

            case (.freestyle(let meme), .freestyle(let text)):
                play(text: text, for: meme, as: player)

            case (.choosing(let meme), .choose(let text)):
                choose(text: text, for: meme, as: player)

            case (_, .end):
                guard player.isHost else {
                    player.send(event: .error(.onlyTheHostCanEnd))
                    return
                }
                end()

            default:
                player.send(event: .error(.illegalEvent))
            }
        }
    }

    private func send(event: ServerSideEvent) {
        for player in players {
            player.send(event: event)
        }
    }

    private func start(as player: Player) {
        guard host?.id == player.id else {
            return player.send(event: .error(.onlyTheHostCanStart))
        }

        guard players.count > 2 else {
            return player.send(event: .error(.gameCanOnlyStartWithAMinimumOfThreePlayers))
        }

        players.shuffle()
        for player in players {
            for _ in 0..<7 {
                player.cards.append(deck.card(for: player, in: self))
            }
            player.send(event: .newCards(player.cards))
        }
        state = .collecting(deck.meme(for: players[judgeIndex], in: self))
    }

    private func play(card: Card, for meme: Meme, as player: Player) {
        guard meme.judge.id != player.id else {
            return player.send(event: .error(.judgeCannotPlayACard))
        }

        guard player.cards.contains(card) else {
            return player.send(event: .error(.cannotPlayACardNotInTheHand))
        }

        guard !meme.proposedLines.contains(where: { $0.player.id == player.id }) else {
            return player.send(event: .error(.cannotPlayTwiceForTheSameCard))
        }

        switch card {
        case .freestyle:
            meme.proposedLines = []
            state = .freestyle(meme)
        case .text(let text):
            play(text: text, for: meme, as: player)
        }

        let newCard = deck.card(for: player, in: self)
        player.cards.append(newCard)
        player.send(event: .newCards([newCard]))
    }

    private func play(text: String, for meme: Meme, as player: Player) {
        guard meme.judge.id != player.id else {
            return player.send(event: .error(.judgeCannotPlayACard))
        }

        guard !meme.proposedLines.contains(where: { $0.player.id == player.id }) else {
            return player.send(event: .error(.cannotPlayTwiceForTheSameCard))
        }

        meme.proposedLines.append(Proposal(player: player, text: text))
        send(event: .update(meme))

        if meme.proposedLines.count == players.count - 1 {
            state = .choosing(meme)
        }
    }

    private func choose(text: String, for meme: Meme, as player: Player) {
        guard meme.judge.id == player.id else {
            return player.send(event: .error(.onlyJudgeCanChoose))
        }

        guard let chosen = meme.proposedLines.first(where: { $0.text == text }) else {
            return player.send(event: .error(.cardWasNotPlayed))
        }

        history.append(meme)
        meme.winningCard = chosen
        judgeIndex = (judgeIndex + 1) % players.count
        if (judgeIndex == 0 && history.count >= rounds * players.count) {
            end()
        } else {
            state = .collecting(deck.meme(for: players[judgeIndex], in: self))
        }
    }

    func end() {
        self.state = .ended
    }
}
