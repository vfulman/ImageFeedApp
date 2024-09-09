import UIKit

enum OAuthConstants {
    static let unsplashOAuthTokenURLString = "https://unsplash.com/oauth/token"
}

enum AuthServiceError: Error {
    case invalidRequest
    case duplicateTokenRequest
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

final class OAuth2Service {
    enum NetworkError: Error {
        case codeError
        case loadImageError
    }
    
    static let shared = OAuth2Service()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code
        else {
            completion(.failure(AuthServiceError.duplicateTokenRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                self.lastCode = nil
                switch result {
                case .failure(let error):
                    print("fetchOAuthToken: failure \(error))")
                case .success(let decodedData):
                    completion(.success(decodedData.access_token))
                }
            }
        }
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuthConstants.unsplashOAuthTokenURLString) else {
            print("makeOAuthTokenRequest: Unable to create URLComponents with wtring \(OAuthConstants.unsplashOAuthTokenURLString)")
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
            print("Unable to create URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}



