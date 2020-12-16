
import Foundation
import TokamakDOM

struct CustomButton<Content : View>: View {
    let character: Character
    let content: Content
    let action: () -> Void

    @State
    var listener: KeypressListener?

    @Environment(\.colorScheme)
    var colorScheme

    @State
    private var isPressed = false

    init(character: Character, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.character = character
        self.content = content()
        self.action = action
    }

    var body: some View {
        VStack {
            DynamicHTML(
                "button",
                ["style" : buttonCss],
                listeners: [
                    "pointerdown": { _ in
                        self.isPressed = true
                    },
                    "pointerup": { _ in
                        self.isPressed = false
                        action()
                    }
                ]
            ) {
                content
            }

            Spacer().frame(width: 0, height: 4)

            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(colorScheme == .light ? Color.black : Color.white)
                    .frame(width: 30, height: 30)

                switch character {
                case .enter:
                    Text("⏎").foregroundColor(colorScheme == .light ? Color.white : Color.black)
                case .space:
                    Text("␣").foregroundColor(colorScheme == .light ? Color.white : Color.black)
                default:
                    Text(String(character)).foregroundColor(colorScheme == .light ? Color.white : Color.black)
                }
            }
            .frame(width: 30, height: 30)
        }.onAppear {
            self.listener = KeypressListener(for: character) { (isPressed: Bool) in
                if isPressed {
                    self.isPressed = true
                } else {
                    self.isPressed = false
                    action()
                }
            }
        }.onDisappear {
            self.listener?.delete()
        }
    }
}

extension CustomButton {
    private var buttonCss: String {
        return """
        background-color: Transparent;
        background-repeat:no-repeat;
        border: none;
        cursor:pointer;
        overflow: hidden;
        outline:none;
        opacity: \(isPressed ? 0.7 : 1)
        """
    }
}
