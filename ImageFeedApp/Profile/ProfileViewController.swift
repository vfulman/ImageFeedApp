//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 26.08.2024.
//

import UIKit
import WebKit

final class ProfileViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let bioLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
    
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createProfileImageView()
        createNameLabel()
        createLoginNameLabel()
        createBioLabel()
        createLogoutButton()
        updateProfileDetails(profile: profileService.profile)
    }

    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile
        else {
            print("updateProfileDetails: Can not update profile info")
            return
        }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        bioLabel.text = profile.bio
        
    }
    
    private func createProfileImageView() {
        let profileImage = UIImage(resource: .defaultUserpic)
        profileImageView.image = profileImage
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.widthAnchor.constraint(equalToConstant: 70.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    private func createNameLabel() {
        nameLabel.text = "Name"
        nameLabel.font = UIFont(name: "SFPro-Bold", size: 23)
        nameLabel.textColor = UIColor.ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createLoginNameLabel() {
        loginNameLabel.text = "@login_name"
        loginNameLabel.font = UIFont(name: "SFPro-Normal", size: 13)
        loginNameLabel.textColor = UIColor.ypGray
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createBioLabel() {
        bioLabel.text = "Bio Info"
        bioLabel.font = UIFont(name: "SFPro-Normal", size: 13)
        bioLabel.textColor = UIColor.ypWhite
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bioLabel)
        bioLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        bioLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createLogoutButton() {
        logoutButton.setImage(UIImage(resource: .logout), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        logoutButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapLogoutButton() {
        storage.removeToken()
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("didTapLogoutButton: Invalid window configuration")
            return
        }
        let splashScreenController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "SplashScreenId")
        window.rootViewController = splashScreenController
    }
}

