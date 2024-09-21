import UIKit


struct Profile {
    let username:String
    let name: String
    let loginName: String
    let bio: String
}

final class ProfileService {
    static let shared = ProfileService()

    var lastToken: String?
    var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    private enum ProfileServiceConstants {
        static let unsplashUserProfileURLString = "\(Constants.defaultBaseURL)/me"
    }
    private struct ProfileResultBody: Decodable {
        let username: String
        let firstName: String
        let lastName: String?
        let bio: String?
        let email: String
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
            case email
        }
    }
    
    private init() {}
    
    func clearProfileInfo() {
        profile = nil
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileInfoRequest(token: token)
        else {
            print("\(#file):\(#function):\(NetworkError.invalidRequest.description)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<ProfileResultBody, NetworkError>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                switch result {
                case .failure(let error):
                    print("\(#file):\(#function):Fetch profile failure \(error.description))")
                    completion(.failure(error))
                case .success(let decodedProfileData):
                    let lastName = decodedProfileData.lastName == nil ? "" : " \(decodedProfileData.lastName ?? "")"
                    self.profile = Profile(
                        username: decodedProfileData.username,
                        name: decodedProfileData.firstName + lastName,
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
            print("\(#file):\(#function): Can not create URL from \(ProfileServiceConstants.unsplashUserProfileURLString)")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
