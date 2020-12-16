
import Foundation

extension CustomButton where Content == StandardButtonContent {

    init(_ text: String, character: Character, action: @escaping () -> Void) {
        self.init(character: character, action: action) {
            StandardButtonContent(text: text)
        }
    }

}

struct StandardButtonContent: View {
    @Environment(\.colorScheme)
    var colorScheme
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(colorScheme == .light ? Color.black : Color.white)
                .frame(width: 200, height: 70)

            Text(text).foregroundColor(colorScheme == .light ? Color.white : Color.black).font(.title3)
        }
        .frame(width: 200, height: 70)
    }
}
