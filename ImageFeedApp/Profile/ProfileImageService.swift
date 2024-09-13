import UIKit


final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    var lastUsername: String?
    var task: URLSessionTask?
    
    private(set) var profileImageURL: String?
    
    private enum ProfileImageServiceConstants {
        static let unsplashUserPublicProfileURLString = "\(Constants.defaultBaseURL)/users/"
    }
    
    struct UserResultBody: Decodable {
        let username: String
        let name: String
        let firstName: String
        let lastName: String?
        let bio: String?
        let profileImage: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case username
            case name
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
            case profileImage = "profile_image"
        }
    }
    
    private init() {}
    
    func clearProfileImageInfo() {
        profileImageURL = nil
    }
    
    func fetchProfileImageURL(_ username: String, _ token: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        guard let request = makeProfileImageRequest(username: username, token: token)
        else {
            print("\(#file):\(#function):\(NetworkError.invalidRequest.description)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResultBody, NetworkError>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                switch result {
                case .failure(let error):
                    print("\(#file):\(#function): failure \(error.description))")
                    completion(.failure(error))
                case .success(let decodedUserData):
                    self.profileImageURL = decodedUserData.profileImage["large"]
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
            print("\(#file):\(#function): Can not create URL from \(ProfileImageServiceConstants.unsplashUserPublicProfileURLString)\(username)")
            return nil
        }
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

