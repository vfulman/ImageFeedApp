//
//  OAuth2TokenStorage.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 02.09.2024.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let storage:UserDefaults = .standard
    
    func storeToken(_ token: String) -> Bool {
        let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
        guard isSuccess else {
            print("OAuth2TokenStorage: Token saving failed")
            return isSuccess
        }
        return isSuccess
    }
    
    func loadToken() -> String? {
        let token: String? = KeychainWrapper.standard.string(forKey: "Auth token")
        return token
    }
    
    func removeToken() -> Bool {
        let isSuccess: Bool = KeychainWrapper.standard.removeObject(forKey: "Auth token")
        guard isSuccess else {
            print("OAuth2TokenStorage: Token removing failed")
            return isSuccess
        }
        return isSuccess
    }
}

