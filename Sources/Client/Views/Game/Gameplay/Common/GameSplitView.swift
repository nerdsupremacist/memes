
import Foundation
import TokamakDOM

struct GameSplitView<Top : View, Center : View, Bottom : View> : View {
    let top: Top
    let center: (Double) -> Center
    let bottom: (Double) -> Bottom

    init(@ViewBuilder top: @escaping () -> Top, @ViewBuilder center: @escaping (Double) -> Center, @ViewBuilder bottom: @escaping (Double) -> Bottom) {
        self.top = top()
        self.center = center
        self.bottom = bottom
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer().frame(width: 0, height: 64)

                top

                Spacer()

                center(proxy.size.height / 3).frame(height: proxy.size.height / 3)

                Spacer()

                bottom(proxy.size.height / 3).frame(height: proxy.size.height / 3)

                Spacer().frame(width: 0, height: 64)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}
