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
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    var lastUsername: String?
    var task: URLSessionTask?
    
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
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResultBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                self.lastUsername = nil
                switch result {
                case .failure(let error):
                    print("fetchProfileImageURL: failure \(error))")
                case .success(let decodedUserData):
                    self.profileImageURL = decodedUserData.profile_image["large"]
                    completion(.success(()))
                    NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.profileImageURL as Any]
                    )
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

