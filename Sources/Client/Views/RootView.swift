
import TokamakDOM

struct RootView: View {
    @ObservedObject
    var session: Session

    var body: some View {
        switch (session.game, session.error) {
        case (.some(let game), .none):
            GameRootView(session: session, game: game)
        case (_, .some(let error)):
            ErrorView(error: error, session: session)
        case (.none, .none):
            GameStartView(session: session)
        }
    }
}
