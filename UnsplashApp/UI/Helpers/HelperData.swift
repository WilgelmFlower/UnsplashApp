import UIKit

class HelperData {
    static let shared = HelperData()
    private init() {}
    var fetchedData = [ResultSearchPhotos]()
}
