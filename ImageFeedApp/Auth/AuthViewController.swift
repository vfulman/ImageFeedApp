//
//  AuthViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 30.08.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let logoImageView = UIImageView()
    private let loginButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createProfileImageView()
        createLoginButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == ShowWebViewSegueIdentifier
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard let webViewViewController = segue.destination as? WebViewViewController
        else {
            fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")
        }
        webViewViewController.delegate = self
    }
    
    private func createProfileImageView() {
        let logoImage = UIImage(resource: .authScreenLogo)
        logoImageView.image = logoImage
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        logoImageView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func createLoginButton() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.backgroundColor = UIColor(resource: .ypWhite)
        loginButton.layer.cornerRadius = 16.0
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        view.addSubview(loginButton)
        loginButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90).isActive = true
    }
    
    @objc
    private func didTapLoginButton() {
        performSegue(withIdentifier: ShowWebViewSegueIdentifier, sender: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // TODO LATER
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}



