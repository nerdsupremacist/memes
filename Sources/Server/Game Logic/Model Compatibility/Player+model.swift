
import Foundation
import Model

extension Player {

    func model() -> Model.Player {
        return Model.Player(id: id, emoji: emoji, name: name, winCount: winCount, isHost: isHost)
    }

}
