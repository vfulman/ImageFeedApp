import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let storage:UserDefaults = .standard
    
    private enum Keys {
        static let authToken = "Auth token"
    }
    
    func storeToken(_ token: String) -> Bool {
        let isSuccess = KeychainWrapper.standard.set(token, forKey: Keys.authToken)
        guard isSuccess else {
            print("\(#file):\(#function): Token saving failed")
            return isSuccess
        }
        return isSuccess
    }
    
    func loadToken() -> String? {
        let token: String? = KeychainWrapper.standard.string(forKey: Keys.authToken)
        return token
    }
    
    func removeToken() -> Bool {
        let isSuccess = KeychainWrapper.standard.removeObject(forKey: Keys.authToken)
        guard isSuccess else {
            print("\(#file):\(#function): Token removing failed")
            return isSuccess
        }
        return isSuccess
    }
}

