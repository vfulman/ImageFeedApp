import ImageFeedApp
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    func logout() {
        profile = nil
    }
    
    var profileImageUrl: String?
    
    var profile: ImageFeedApp.Profile? = Profile(
        username: "test_username",
        name: "",
        loginName: "",
        bio: ""
    )
    

}
