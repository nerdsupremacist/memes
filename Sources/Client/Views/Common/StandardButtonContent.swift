
import Foundation
import TokamakDOM

struct StandardButtonContent: View {
    @Environment(\.colorScheme)
    var colorScheme

    let text: String
    let width: Double
    let height: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(colorScheme == .light ? Color.black : Color.white)
                .frame(width: width, height: height)

            Text(text).foregroundColor(colorScheme == .light ? Color.white : Color.black).font(.title3)
        }
        .frame(width: width, height: height)
    }

    init(_ text: String, width: Double = 200, height: Double = 70) {
        self.text = text
        self.width = width
        self.height = height
    }
}
