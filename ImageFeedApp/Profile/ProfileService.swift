//
//  ProfileService.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 04.09.2024.
//

import UIKit

struct ProfileResultBody: Decodable {
    let id: String
    let updated_at : String
    let username: String
    let first_name: String
    let last_name: String?
    let twitter_username: String?
    let portfolio_url: String?
    let bio: String?
    let location: String?
    let total_likes: Int
    let total_photos: Int
    let total_collections: Int
    let followed_by_user: Bool
    let downloads: Int
    let uploads_remaining: Int
    let instagram_username: String?
    let email: String
    let links: [String: String]
}

struct Profile {
    let username:String
    let name: String
    let loginName: String
    let bio: String
}

enum ProfileServiceError: Error {
    case invalidRequest
    case duplicateTokenRequest
}

enum ProfileServiceConstants {
    static let unsplashUserProfileURLString = "\(Constants.defaultBaseURL)/me"
}

final class ProfileService {
    var lastToken: String?
    var task: URLSessionTask?
    
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token
        else {
            completion(.failure(ProfileServiceError.duplicateTokenRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileInfoRequest(token: token)
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) {[weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.task = nil
                self.lastToken = nil
                
                switch result {
                case .failure(let error):
                    print("fetchProfile: failure \(error))")
                case .success(let data):
                    do {
                        let profileData = try JSONDecoder().decode(ProfileResultBody.self, from: data)
                        let lastName = profileData.last_name == nil ? "" : " \(profileData.last_name ?? "")"
                        self.profile = Profile(
                            username: profileData.username,
                            name: profileData.first_name + lastName,
                            loginName: "@\(profileData.username)",
                            bio: profileData.bio ?? "")
                        completion(.success(()))
                    } catch {
                        print("fetchProfile: Decoding failure \(error)")
                        completion(.failure(error))
                    }
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
