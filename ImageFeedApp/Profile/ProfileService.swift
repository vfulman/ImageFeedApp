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
        let first_name: String
        let last_name: String?
        let bio: String?
        let email: String
    }
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileInfoRequest(token: token)
        else {
            completion(.failure(NetworkServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<ProfileResultBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                switch result {
                case .failure(let error):
                    print("fetchProfile: failure \(error))")
                    completion(.failure(error))
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
            print("makeProfileInfoRequest: Can not create URL from \(ProfileServiceConstants.unsplashUserProfileURLString)")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
