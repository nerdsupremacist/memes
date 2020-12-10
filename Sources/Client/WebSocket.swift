
import Foundation
import OpenCombine
import JavaScriptKit

class WebSocket {
    private static let constructor = JSObject.global.WebSocket.function!
    private let object: JSObject
    private var queue: [String] = []
    private var isOpen = false

    init(url: URL) {
        self.object = Self.constructor.new(url.absoluteString)

        var closure: JSClosure?
        closure = JSClosure { [weak self] _ -> Void in
            guard let self = self else { return }
            self.isOpen = true
            for message in self.queue {
                self.send(message)
            }
            if let closure = closure {
                closure.release()
                _ = self.object.removeEventListener!("open", closure)
            }
            closure = nil
        }

        _ = object.addEventListener!("open", closure)
    }

    func send(_ message: String) {
        if isOpen {
            _ = object.send!(message)
        } else {
            queue.append(message)
        }
    }

    func close() {
        _ = object.close!()
    }

    func messages() -> AnyPublisher<String, Never> {
        let object = self.object
        let subject = PassthroughSubject<String, Never>()

        let onMessage = JSClosure { arguments -> Void in
            let event = arguments.first!.object!
            let data = event["data"].string!
            subject.send(data)
        }

        var onClose: JSClosure?
        onClose = JSClosure { arguments -> Void in
            _ = self.object.removeEventListener!("message", onMessage)
            _ = self.object.removeEventListener!("close", onClose)
            subject.send(completion: .finished)
            onMessage.release()
            onClose?.release()
        }

        _ = object.addEventListener!("message", onMessage)
        _ = object.addEventListener!("close", onClose)
        return subject.eraseToAnyPublisher()
    }

    func onClose() -> AnyPublisher<Void, Never> {
        let subject = PassthroughSubject<Void, Never>()
        var onClose: JSClosure?
        onClose = JSClosure { arguments -> Void in
            _ = self.object.removeEventListener!("close", onClose)
            subject.send()
            subject.send(completion: .finished)
            onClose?.release()
        }

        _ = object.addEventListener!("close", onClose)
        return subject.eraseToAnyPublisher()
    }
}

extension WebSocket {

    func send<T : Encodable>(_ value: T)  {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(value), let string = String(data: encoded, encoding: .utf8) else { return }
        send(string)
    }

}

extension WebSocket {

    func messages<T : Decodable>(type: T.Type) -> AnyPublisher<T, Never> {
        return messages()
            .map { string in
                let data = string.data(using: .utf8)!
                let decoder = JSONDecoder()
                return try! decoder.decode(type, from: data)
            }
            .eraseToAnyPublisher()
    }

}
