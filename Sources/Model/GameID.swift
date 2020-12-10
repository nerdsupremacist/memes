
import Foundation

public struct GameID: RawRepresentable, Codable, Hashable {
    public let rawValue: String

    public init() {
        let array = [UInt8].random(count: 4)
        let data = Data(array)
        self.rawValue = data.base64EncodedString().replacingOccurrences(of: "[^a-zA-Z0-9-]", with: "", options: .regularExpression)
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Array where Element: FixedWidthInteger {
    static func random(count: Int) -> [Element] {
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random() }
        return array
    }
}

extension FixedWidthInteger {
    static func random() -> Self {
        return Self.random(in: .min ... .max)
    }
}
