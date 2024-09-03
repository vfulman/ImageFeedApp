//
//  OAuth2Service.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 01.09.2024.
//

import UIKit



enum OAuthConstants {
    static let unsplashOAuthTokenURLString = "https://unsplash.com/oauth/token"
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
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: OAuthConstants.unsplashOAuthTokenURLString) else {
            preconditionFailure("makeOAuthTokenRequest: Unable to create URLComponents with wtring \(OAuthConstants.unsplashOAuthTokenURLString)")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            preconditionFailure("Unable to create URLComponents")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard self != nil else {return}
                switch result {
                case .failure(let error):
                    print("fetchOAuthToken: failure \(error))")
                case .success(let data):
                    do {
                        let tokenData = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        completion(.success(tokenData.access_token))
                    } catch {
                        print("fetchOAuthToken: Decoding failure \(error)")
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
}



