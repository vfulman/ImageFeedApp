//
//  AuthViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 30.08.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    private let oAuth2Service = OAuth2Service.shared
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let logoImageView = UIImageView()
    private let loginButton = UIButton(type: .custom)
    
    private let storage = OAuth2TokenStorage()
    private let alertPresenter = AlertPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        createProfileImageView()
        createLoginButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showWebViewSegueIdentifier
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard let webViewViewController = segue.destination as? WebViewViewController
        else {
            assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
            return
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
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let accessToken):
                self.storage.storeToken(accessToken)
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("webViewViewController: Cant fetch token by \(code). \(error)")
                alertPresenter.showAlert()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}

extension AuthViewController: AlertPresenterDelegate {
    func present(_ alertToPresent: UIAlertController) {
        present(alertToPresent, animated: true)
    }
}

