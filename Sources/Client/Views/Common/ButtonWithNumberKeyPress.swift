
import Foundation
import TokamakDOM

struct ButtonWithNumberKeyPress<Content : View>: View {
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

extension ButtonWithNumberKeyPress where Content == SomeButtonLook {

    init(_ text: String, character: Character, action: @escaping () -> Void) {
        self.init(character: character, action: action) {
            SomeButtonLook(text: text)
        }
    }

}

struct SomeButtonLook: View {
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

extension ButtonWithNumberKeyPress {
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
