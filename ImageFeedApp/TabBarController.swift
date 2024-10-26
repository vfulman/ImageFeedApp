import UIKit


final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .ypWhite
        UITabBar.appearance().barTintColor = .ypBlack
        UITabBar.appearance().backgroundColor = .ypBlack
        UITabBar.appearance().isTranslucent = false
        setupTabBar()
    }

    func setupTabBar() {
        let imageListPresenter = ImagesListPresenter()
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.presenter = imageListPresenter
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        
        let profilePresenter = ProfilePresenter()
        let profileViewController = ProfileViewController()
        profileViewController.presenter = profilePresenter

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        viewControllers = [imagesListViewController, profileViewController]
    }
    
}
