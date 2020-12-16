
import Foundation
import TokamakDOM

struct StandardButtonContent: View {
    @Environment(\.colorScheme)
    var colorScheme

    let text: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(colorScheme == .light ? Color.black : Color.white)
                .frame(width: 200, height: 70)

            Text(text).foregroundColor(colorScheme == .light ? Color.white : Color.black).font(.title3)
        }
        .frame(width: 200, height: 70)
    }

    init(_ text: String, width: CGFloat = 200, height: CGFloat = 70) {
        self.text = text
        self.width = width
        self.height = height
    }
}
