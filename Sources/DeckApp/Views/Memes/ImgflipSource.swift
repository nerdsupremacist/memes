
import Foundation

final class ImgflipSource: MemeImageSource {
    private let url = URL(string: "https://api.imgflip.com/get_memes")!

    var hasMore: Bool = true

    init() { }

    func loadMore(completion: @escaping (Result<[URL], Error>) -> Void) {
        guard hasMore else { return }
        hasMore = false

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(response.data.memes.map(\.url)))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

extension ImgflipSource {
    struct Meme: Decodable {
        let url: URL
    }

    struct Data: Decodable {
        let memes: [Meme]
    }

    struct Response: Decodable {
        let data: Data
    }
}
