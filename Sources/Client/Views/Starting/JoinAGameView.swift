
import Foundation
import TokamakDOM
import Model

struct JoinAGameView: View {
    var session: Session

    @State
    private var room = ""

    func start() {
        session.join(id: GameID(rawValue: room))
    }

    var body: some View {
        VStack {
            Text("Enter the Room #").font(.title)
            Text("The person hosting the game should've given you a code by now...").font(.callout).fontWeight(.regular)

            Spacer().frame(width: 0, height: 4)

            CustomTextField(placeholder: "Room #", text: $room) { start() }
        }
    }
}
