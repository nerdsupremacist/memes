
import Foundation

struct GameID: RawRepresentable, Codable, Hashable {
    let rawValue: String

    init() {
        self.rawValue = [UInt8].random(count: 4).base64.replacingOccurrences(of: "=", with: "")
    }

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
