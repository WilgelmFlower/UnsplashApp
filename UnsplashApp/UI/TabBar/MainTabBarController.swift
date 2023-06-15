import UIKit

class MainTabBarController: UITabBarController {

    var fetchedData = [ResultSearchPhotos]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }

    private func setupControllers() {
        let homeVC = ViewController()
        let favouriteVC = FavouriteViewController()

        let homeNavVC = UINavigationController(rootViewController: homeVC)
        let favouriteNavVC = UINavigationController(rootViewController: favouriteVC)

        homeVC.title = "Unsplash Photos"
        favouriteVC.title = "Favourite Photos"

        let homeTabBarItem = UITabBarItem(title: "Photos", image: UIImage(systemName: "photo.stack"), selectedImage: nil)
        homeTabBarItem.tag = 0
        homeVC.tabBarItem = homeTabBarItem

        let favouriteTabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "heart.square.fill"), selectedImage: nil)
        favouriteTabBarItem.tag = 1
        favouriteVC.tabBarItem = favouriteTabBarItem

        self.setViewControllers([homeNavVC, favouriteNavVC], animated: true)
    }

    func configure(items: ResultSearchPhotos) {
        fetchedData.append(items)
        if let favouriteNavVC = self.viewControllers?[1] as? UINavigationController,
           let favouriteVC = favouriteNavVC.topViewController as? FavouriteViewController {
            favouriteVC.resultsTab = fetchedData
        }
    }

    func removeModel(withId id: String) {
        fetchedData.removeAll(where: { $0.id == id })
        if let favoritesVC = viewControllers?[1] as? UINavigationController,
           let favoritesRootVC = favoritesVC.viewControllers.first as? FavouriteViewController {
            favoritesRootVC.resultsTab.removeAll(where: { $0.id == id })
            favoritesRootVC.tableView.reloadData()
        }
    }
}
