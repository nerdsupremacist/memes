
import Foundation
import TokamakDOM
import Model

struct CardView: View {
    let game: Game
    let card: Card
    let index: Int
    let height: Double

    @Environment(\.colorScheme)
    var colorScheme

    var effectiveColorScheme: ColorScheme {
        guard isFreeStyle else { return colorScheme }
        switch colorScheme {
        case .light:
            return .dark
        case .dark:
            return .light
        }
    }

    var isFreeStyle: Bool {
        guard case .freestyle = card else { return false }
        return true
    }

    var text: String {
        switch card {
        case .text(let text):
            return text
        case .freestyle:
            return "Freestyle!"
        }
    }

    var body: some View {
        CustomButton(character: String(index + 1).first!, action: { game.play(card: card) }) {
            CardContentView(card: card, height: height - 46)
        }
        .frame(height: height)
    }
}
