//
//  OAuth2TokenStorage.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 02.09.2024.
//

import UIKit

final class OAuth2TokenStorage {
    private enum Keys: String {
        case bearerToken
    }
    
    private let storage:UserDefaults = .standard
    
    private var bearerToken: String? {
        get {
            storage.string(forKey: Keys.bearerToken.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: Keys.bearerToken.rawValue)
        }
    }
    
    func storeToken(_ tokenValue: String) {
        bearerToken = tokenValue
    }
    
    func loadToken() -> String? {
        return bearerToken
    }
    
    func removeToken() {
        storage.removeObject(forKey: Keys.bearerToken.rawValue)
    }
}

