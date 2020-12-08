
import Foundation
import Model

extension Proposal {
    func model() -> Model.Proposal {
        return Model.Proposal(player: player.model(), text: text)
    }
}
