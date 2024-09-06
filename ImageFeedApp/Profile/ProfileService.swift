//
//  ProfileService.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 04.09.2024.
//

import UIKit

struct ProfileResultBody: Decodable {
    let username: String
    let first_name: String
    let last_name: String?
    let bio: String?
    let email: String
}

struct Profile {
    let username:String
    let name: String
    let loginName: String
    let bio: String
}

enum ProfileServiceError: Error {
    case invalidRequest
    case duplicateProfileInfoRequest
}

enum ProfileServiceConstants {
    static let unsplashUserProfileURLString = "\(Constants.defaultBaseURL)/me"
}

final class ProfileService {
    static let shared = ProfileService()

    var lastToken: String?
    var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token
        else {
            completion(.failure(ProfileServiceError.duplicateProfileInfoRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileInfoRequest(token: token)
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<ProfileResultBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                self.lastToken = nil
                switch result {
                case .failure(let error):
                    print("fetchProfile: failure \(error))")
                case .success(let decodedProfileData):
                    let lastName = decodedProfileData.last_name == nil ? "" : " \(decodedProfileData.last_name ?? "")"
                    self.profile = Profile(
                        username: decodedProfileData.username,
                        name: decodedProfileData.first_name + lastName,
                        loginName: "@\(decodedProfileData.username)",
                        bio: decodedProfileData.bio ?? "")
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
    
    private func makeProfileInfoRequest(token: String) -> URLRequest? {
        guard let url = URL(string: ProfileServiceConstants.unsplashUserProfileURLString)
        else {
            print("makeProfileInfoRequest: Can not create UTL from \(ProfileServiceConstants.unsplashUserProfileURLString)")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
