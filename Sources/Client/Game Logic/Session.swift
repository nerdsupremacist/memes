
import TokamakDOM
import CombineShim
import Foundation
import Model

class Session: ObservableObject {
    private let url: URL

    @Published
    private(set) var game: Game?

    @Published
    private(set) var error: GameError?
    private var cancellables: Set<AnyCancellable> = []

    init(url: URL) {
        self.url = url
    }

    convenience init(id: GameID?, url: URL) {
        self.init(url: url)
        if let id = id {
            join(id: id)
        }
    }

    private func startGame() -> Game {
        cancellables = []
        let socket = WebSocket(url: url)
        socket
            .onClose()
            .sink { [unowned self] in
                self.game = nil
                changeQueryParameters { $0.filter { $0.name != "id" } }
            }
            .store(in: &cancellables)

        let game = Game(webSocket: socket)
        self.game = game

        game
            .$error
            .sink { [unowned self] error in self.error = error }
            .store(in: &cancellables)

        return game
    }

    func join(id: GameID) {
        if let game = game {
            game.join(id: id)
        } else {
            startGame().join(id: id)
        }
    }

    func configure(rounds: Int) {
        if let game = game {
            game.configure(rounds: rounds)
        } else {
            startGame().configure(rounds: rounds)
        }
    }

    func clearError() {
        self.error = nil
    }
}
