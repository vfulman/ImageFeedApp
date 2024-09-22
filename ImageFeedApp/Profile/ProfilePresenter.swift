import UIKit


public protocol ProfilePresenterProtocol {
    func logout()
    var profileImageUrl: String? { get }
    var profile: Profile? { get }
}


final class ProfilePresenter: ProfilePresenterProtocol {
    private let profileService =  ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    var profileImageUrl: String? {
        return profileImageService.profileImageURL
    }
    
    var profile: Profile? {
        return profileService.profile
    }
    
    func logout() {
        self.profileLogoutService.logout()
    }
}
