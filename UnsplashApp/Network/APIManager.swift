import Alamofire

private enum NetworkConstants {
    static let baseURL = "https://api.unsplash.com"
    static let clientID = "w8ZPpc08Dps3V2901Qlp2MRqS6vw3m65fk8tM-QknK8"
}

class APIManager {
    static let shared = APIManager()
    private let perPage = 10

    func fetchPhotos<T: Decodable>(withQuery query: String? = nil, page: Int = 0, completion: @escaping (Result<T, Error>) -> Void) {
        let endpoint: String
        var parameters: [String: Any] = [
            "client_id": NetworkConstants.clientID,
            "per_page": perPage,
            "page": page
        ]

        if let query = query {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            endpoint = "\(NetworkConstants.baseURL)/search/photos"
            parameters["query"] = encodedQuery
        } else {
            endpoint = "\(NetworkConstants.baseURL)/photos"
        }

        AF.request(endpoint, parameters: parameters, encoding: URLEncoding.default).validate().responseDecodable(of: T.self) { response in
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
