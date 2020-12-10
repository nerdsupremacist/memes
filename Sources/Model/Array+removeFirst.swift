
import Foundation

extension Array {

    public mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows {
        guard let index = try firstIndex(where: predicate) else { return }
        remove(at: index)
    }

}

extension Array where Element: Equatable {

    public mutating func removeFirst(_ element: Element) {
        removeFirst { $0 == element }
    }

}
