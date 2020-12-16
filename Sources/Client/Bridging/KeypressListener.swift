
import Foundation
import JavaScriptKit

class KeypressListener {
    private var listeners: [String : JSClosure]

    private init(listeners: [String : JSClosure]) {
        self.listeners = listeners
    }

    deinit {
        delete()
    }

    func delete() {
        let document = JSObject.global.document
        for (type, listener) in listeners {
            _ = document.removeEventListener(type, listener)
            listener.release()
        }
        listeners = [:]
    }
}

extension KeypressListener {

    convenience init(for characters: Character..., action: @escaping () -> Void) {
        self.init(characters: characters) { _, isPressed in
            if !isPressed {
                action()
            }
        }
    }

    convenience init(for characters: Character..., action: @escaping (Bool) -> Void) {
        self.init(characters: characters) { _, isPressed in action(isPressed) }
    }

    convenience init(for characters: Character..., action: @escaping (Character) -> Void) {
        self.init(characters: characters) { character, isPressed in
            if !isPressed {
                action(character)
            }
        }
    }

    convenience init(for characters: Character..., action: @escaping (Character, Bool) -> Void) {
        self.init(characters: characters, action: action)
    }

    convenience private init(characters: [Character], action: @escaping (Character, Bool) -> Void) {
        let set = Set(characters)

        func doit(arguments: [JSValue], isPressed: Bool) {
            let event = arguments.first ?? JSObject.global.window
            let keyCode = event.object!["keyCode"]
            let character = Character(Unicode.Scalar(UInt8(Int(keyCode.number!))))
            if set.contains(character) {
                action(character, isPressed)
            }
        }

        let keyup = JSClosure { arguments -> Void in
            doit(arguments: arguments, isPressed: false)
        }

        let keydown = JSClosure { arguments -> Void in
            doit(arguments: arguments, isPressed: true)
        }

        _ = JSObject.global.document.addEventListener("keyup", keyup, false)
        _ = JSObject.global.document.addEventListener("keydown", keydown, false)

        let listeners = [
            "keyup" : keyup,
            "keydown" : keydown,
        ]
        self.init(listeners: listeners)
    }

}

extension Character {
    static let enter = Character(Unicode.Scalar(13))
    static let space = Character(Unicode.Scalar(32))
}
