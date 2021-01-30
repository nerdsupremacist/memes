
import Foundation

protocol MemeImageSource {
    var hasMore: Bool { get }
    init()
    func loadMore(completion: @escaping (Result<[URL], Error>) -> Void)
}
