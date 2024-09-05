//
//  SplashViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 02.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private enum seguesId: String {
        case showAuthViewSegueIdentifier = "showAuthView"
        case showImagesListViewSegueIdentifier = "showImagesListView"
    }
    
    private let launchLogoImageView = UIImageView()
    private let storage = OAuth2TokenStorage()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLogo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seguesId.showAuthViewSegueIdentifier.rawValue {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(seguesId.showAuthViewSegueIdentifier.rawValue)")
                return
            }
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.loadToken() {
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: seguesId.showAuthViewSegueIdentifier.rawValue, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
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
                    profileImageService.fetchProfileImageURL(username, token) { _ in }
                }
                switchToTabBarController()
            case .failure(let error):
                assertionFailure("updateProfileInfo: Cant update profile info by token. \(error)")
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.loadToken()
        else {
            print("didAuthenticate: authorization token was not found")
            return
        }
        fetchProfile(token)
    }
}
