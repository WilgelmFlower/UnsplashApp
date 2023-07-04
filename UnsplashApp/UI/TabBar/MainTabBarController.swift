import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }

    private func setupControllers() {
        let tabBarAppereance = UITabBarAppearance()
        tabBarAppereance.backgroundColor = UIColor(named: "tabBarColor")

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
}
