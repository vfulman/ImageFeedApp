//
//  ProfileImageService.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 05.09.2024.
//

import UIKit

struct UserResultBody: Decodable {
    let username: String
    let name: String
    let first_name: String
    let last_name: String?
    let bio: String?
    let profile_image: [String: String]
    
}

enum ProfileImageServiceError: Error {
    case invalidRequest
    case duplicateProfileImageURLRequest
}

enum ProfileImageServiceConstants {
    static let unsplashUserPublicProfileURLString = "\(Constants.defaultBaseURL)/users/"
}

final class ProfileImageService {
    
    var lastUsername: String?
    var task: URLSessionTask?
    static let shared = ProfileImageService()
    
    private let storage = OAuth2TokenStorage()
    
    private(set) var profileImageURL: String?
    
    private init() {}
    
    func fetchProfileImageURL(_ username: String, _ token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastUsername != username
        else {
            completion(.failure(ProfileImageServiceError.duplicateProfileImageURLRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard let request = makeProfileImageRequest(username: username, token: token)
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) {[weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.task = nil
                self.lastUsername = nil
                
                switch result {
                case .failure(let error):
                    print("fetchProfileImageURL: failure \(error))")
                case .success(let data):
                    do {
                        let userData = try JSONDecoder().decode(UserResultBody.self, from: data)
                        self.profileImageURL = userData.profile_image["small"]
                        completion(.success(()))
                    } catch {
                        print("fetchProfileImageURL: Decoding failure \(error)")
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: ProfileImageServiceConstants.unsplashUserPublicProfileURLString + username)
        else {
            print("makeProfileInfoRequest: Can not create UTL from \(ProfileImageServiceConstants.unsplashUserPublicProfileURLString)\(username)")
            return nil
        }
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
