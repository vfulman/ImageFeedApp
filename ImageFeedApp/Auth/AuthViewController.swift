import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    private let oAuth2Service = OAuth2Service.shared
    private let logoImageView = UIImageView()
    private let loginButton = UIButton(type: .custom)
    
    private let webViewViewController = WebViewViewController()
    private let storage = OAuth2TokenStorage()
    private let alertPresenter = AlertPresenter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        alertPresenter.delegate = self
        webViewViewController.delegate = self
        createProfileImageView()
        createLoginButton()
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
        loginButton.titleLabel?.font = UIFont.init(name: "SFPro-Bold", size: 17)
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
        navigationController?.pushViewController(webViewViewController, animated: true)
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
                if self.storage.storeToken(accessToken) {
                    self.delegate?.didAuthenticate(self)
                }
                else {
                    print("\(#file):\(#function): Cant store token")
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print("\(#file):\(#function): Cant fetch token by \(code). \(error.description)")
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

