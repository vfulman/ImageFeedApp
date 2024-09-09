import UIKit
import WebKit



protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    weak var delegate: WebViewViewControllerDelegate?
    
    private let webView = WKWebView()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypWhite)
        webView.navigationDelegate = self
        createWebView()
        configureBackButton()
        createProgressView()
        loadAuthView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: []) { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()}
    }
    
    private func updateProgress() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
        if progressView.isHidden {
            progressView.setProgress(0.0, animated: false)
        }
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(resource: .backward),
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapBackButton))
        backButton.tintColor = UIColor(resource: .ypBlack)
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("\(#file):\(#function): Can not create urlComponents with string \(WebViewConstants.unsplashAuthorizeURLString)")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("\(#file):\(#function): Can not found url in \(urlComponents)")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func createWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor(resource: .ypWhite)
        view.addSubview(webView)
        webView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    private func createProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(resource: .ypBlack)
        view.addSubview(progressView)
        progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true  
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
