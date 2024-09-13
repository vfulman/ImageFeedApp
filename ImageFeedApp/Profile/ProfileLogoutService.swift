import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    let storage = OAuth2TokenStorage()
    
    private init() { }
    
    func logout() {
        removeUserData()
        cleanCookies()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func removeUserData() {
        let isRemoved = storage.removeToken()
        guard isRemoved else {
            print("\(#file):\(#function): Cant remove token from storage")
            return
        }
        ProfileService.shared.clearProfileInfo()
        ProfileImageService.shared.clearProfileImageInfo()
        ImagesListService.shared.clearPhotosInfo()
    }
}

