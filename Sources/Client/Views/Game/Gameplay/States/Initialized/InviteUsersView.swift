
import Foundation
import TokamakDOM
import JavaScriptKit

struct InviteUserButton: View {
    let game: Game

    @State
    var isCopying = false

    @State
    var timer: JSTimer?

    func copy() {
        guard !isCopying else { return }
        guard var components = URLComponents.current else { return }
        components.queryItems = game.gameID.map { [URLQueryItem(name: "id", value: $0.rawValue)] }

        if let string = components.string {
            Clipboard.write(string)
        }

        isCopying = true

        timer = JSTimer(millisecondsDelay: 1_000) {
            isCopying = false
        }
    }

    var body: some View {
        CustomButton(isCopying ? "Link Copied!" : "Invite Friends", character: "C") { copy() }
    }
}
