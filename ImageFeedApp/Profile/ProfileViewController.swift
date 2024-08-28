//
//  ProfileViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 26.08.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let statusLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createProfileImageView()
        createNameLabel()
        createUserNameLabel()
        createStatusLabel()
        createLogoutButton()
    }
    
    private func createProfileImageView() {
        let profileImage = UIImage(resource: .userpick)
        profileImageView.image = profileImage
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    private func createNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont(name: "SFPro-Bold", size: 23)
        nameLabel.textColor = UIColor.ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createUserNameLabel() {
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = UIFont(name: "SFPro-Normal", size: 13)
        usernameLabel.textColor = UIColor.ypGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        usernameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createStatusLabel() {
        statusLabel.text = "Hello, world!"
        statusLabel.font = UIFont(name: "SFPro-Normal", size: 13)
        statusLabel.textColor = UIColor.ypWhite
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createLogoutButton() {
        logoutButton.setImage(UIImage(resource: .logout), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
}

