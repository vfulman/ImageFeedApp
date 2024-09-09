import UIKit

final class SplashViewController: UIViewController {
    private let launchLogoImageView = UIImageView()
    
    private let storage = OAuth2TokenStorage()
    
    private let authViewController = AuthViewController()
    private let authNavigationontroller = UINavigationController()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authNavigationontroller.viewControllers = [authViewController]
        authNavigationontroller.modalPresentationStyle = .fullScreen
        view.backgroundColor = UIColor(resource: .ypBlack)
        authViewController.delegate = self
        createLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.loadToken() {
            fetchProfile(token)
        } else {
            present(authNavigationontroller, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = TabBarController()
    }
    
    private func createLogo() {
        let launchLogoImage = UIImage(resource: .launchLogo)
        launchLogoImageView.image = launchLogoImage
        launchLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchLogoImageView)
        launchLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        launchLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success():
                if let username = profileService.profile?.username {
                    profileImageService.fetchProfileImageURL(username, token) { result in
                        switch result {
                        case .success():
                            break
                        case .failure(let error):
                            print("\(#file):\(#function): Cant fetch profile image URL of \(username). \(error)")
                        }
                    }
                }
                switchToTabBarController()
            case .failure(let error):
                print("\(#file):\(#function): Cant update profile info by token. \(error)")
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.loadToken()
        else {
            print("\(#file):\(#function): authorization token was not found")
            return
        }
        fetchProfile(token)
    }
}
