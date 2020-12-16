
import Foundation
import TokamakDOM
import Model

struct GameStartView: View {
    @ObservedObject
    var session: Session

    @State
    private var kind: Kind? = nil

    enum Kind {
        case start
        case join
    }

    var body: some View {
        switch kind {
        case .none:
            ChooseKindView(kind: $kind)
        case .some(.start):
            StartANewGameView(session: session)
        case .some(.join):
            JoinAGameView(session: session)
        }
    }
}
