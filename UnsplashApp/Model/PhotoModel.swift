import Foundation

struct PhotoModelSearch: Decodable {
    let results: [ResultSearchPhotos]
}

struct ResultSearchPhotos: Decodable {
    let id: String
    let created_at: String
    let urls: Urls
    let user: User
}

struct PhotoModel: Decodable {
    let id: String
    let created_at: String
    let urls: Urls
    let user: User
}

struct Urls: Decodable {
    let regular: String
}

struct User: Decodable {
    let username: String
    let location: String?
    let total_likes: Int
}
