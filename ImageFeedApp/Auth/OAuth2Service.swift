import UIKit


final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private enum OAuthConstants {
        static let unsplashOAuthTokenURLString = "https://unsplash.com/oauth/token"
    }
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
    
    
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code
        else {
            print("\(#file):\(#function):\(NetworkError.duplicateRequest.description)")
            completion(.failure(NetworkError.duplicateRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            print("\(#file):\(#function):\(NetworkError.invalidRequest.description)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, NetworkError>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                self.lastCode = nil
                switch result {
                case .failure(let error):
                    print("\(#file):\(#function): failure \(error.description))")
                    completion(.failure(error))
                case .success(let decodedData):
                    completion(.success(decodedData.accessToken))
                }
            }
        }
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuthConstants.unsplashOAuthTokenURLString) else {
            print("\(#file):\(#function): Unable to create URLComponents with wtring \(OAuthConstants.unsplashOAuthTokenURLString)")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            print("\(#file):\(#function): Unable to create URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}



