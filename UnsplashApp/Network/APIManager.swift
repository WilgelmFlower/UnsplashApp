import Alamofire

private enum NetworkConstants {
    static let baseURL = "https://api.unsplash.com"
    static let clientID = "w8ZPpc08Dps3V2901Qlp2MRqS6vw3m65fk8tM-QknK8"
}

class APIManager {
    static let shared = APIManager()
    private let perPage = 30

    func fetchPhotos<T: Decodable>(withQuery query: String? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        var urlString = "\(NetworkConstants.baseURL)/photos/?client_id=\(NetworkConstants.clientID)&per_page=\(perPage)"

        if let query = query {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString = "\(NetworkConstants.baseURL)/search/photos?client_id=\(NetworkConstants.clientID)&per_page=\(perPage)&query=\(encodedQuery)"
        }

        AF.request(urlString).validate().responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
                print(String(describing: error))
            }
        }
    }
}
