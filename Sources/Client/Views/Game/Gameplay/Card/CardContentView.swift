
import Foundation
import TokamakDOM
import Model

struct CardContentView: View {
    let card: Card

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
        ZStack {
            RoundedRectangle(cornerRadius: 21)
                .fill(effectiveColorScheme == .light ? Color.white : Color.black)
                .frame(width: 200, height: 300)

            RoundedRectangle(cornerRadius: 20)
                .fill(effectiveColorScheme == .light ? Color.black : Color.white)
                .frame(width: 198, height: 298)

            VStack {
                Text(text).foregroundColor(effectiveColorScheme == .light ? Color.white : Color.black).font(.body).frame(width: 200-8)
            }
        }
        .frame(width: 200, height: 300)
    }
}
