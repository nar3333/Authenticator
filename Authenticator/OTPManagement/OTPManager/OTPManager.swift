//
//  OTPManager.swift
//  Authenticator
//
//  Created by PRO 14 on 16.11.23.
//

import Foundation
import OneTimePassword

class OTPManager {
    static let shared = OTPManager()
    private let store: TokenStore
    
    private init() {
        do {
            store = try KeychainTokenStore(
                keychain: Keychain.sharedInstance,
                userDefaults: UserDefaults.standard
            )
        } catch {
            // If the TokenStore could not be created, the app is unusable.
            fatalError("Failed to load token store: \(error)")
        }
    }
    
    func getStore() -> TokenStore {
        return store
    }
    
    func getAllTokens() -> [PersistentToken] {
        return store.persistentTokens
    }
}
