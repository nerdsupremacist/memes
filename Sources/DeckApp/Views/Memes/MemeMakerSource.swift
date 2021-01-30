
import Foundation

final class MemeMakerSource: MemeImageSource {
    private var next: URL? = URL(string: "https://alpha-meme-maker.herokuapp.com/")!

    var hasMore: Bool {
        return next != nil
    }

    init() { }

    func loadMore(completion: @escaping (Result<[URL], Error>) -> Void) {
        guard let url = next else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                self.next = response.next
                completion(.success(response.data.map(\.image)))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

extension MemeMakerSource {

    struct Meme: Decodable {
        let image: URL
    }

    struct Response: Decodable {
        let data: [Meme]
        let next: URL?
    }

}
