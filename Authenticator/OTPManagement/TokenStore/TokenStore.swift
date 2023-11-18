//
//  TokenStore.swift
//  Authenticator
//
//  Created by PRO 14 on 16.11.23.
//

import Foundation
import OneTimePassword

protocol TokenStore {
    var persistentTokens: [PersistentToken] { get }

    func addToken(_ token: Token) throws
    func saveToken(_ token: Token, toPersistentToken persistentToken: PersistentToken) throws
    func updatePersistentToken(_ persistentToken: PersistentToken) throws
    func moveTokenFromIndex(_ origin: Int, toIndex destination: Int) throws
    func deletePersistentToken(_ persistentToken: PersistentToken) throws
}

class KeychainTokenStore: TokenStore {
    private let keychain: Keychain
    private let userDefaults: UserDefaults
    private(set) var persistentTokens: [PersistentToken]

    // Throws an error if the initial state could not be loaded from the keychain.
    init(keychain: Keychain, userDefaults: UserDefaults) throws {
        self.keychain = keychain
        self.userDefaults = userDefaults
        
//        do {
//            let tokens = try keychain.allPersistentTokens()
//            
//            try tokens.forEach { token in
//                try keychain.delete(token)
//            }
//        } catch {
//            print("pizdec")
//        }
        

        // Try to load persistent tokens.
        let persistentTokenSet = try keychain.allPersistentTokens()
        let sortedIdentifiers = userDefaults.persistentIdentifiers()

        persistentTokens = persistentTokenSet.sorted(by: {
            let indexOfA = sortedIdentifiers.firstIndex(of: $0.identifier)
            let indexOfB = sortedIdentifiers.firstIndex(of: $1.identifier)

            switch (indexOfA, indexOfB) {
            case let (.some(iA), .some(iB)) where iA < iB:
                return true
            default:
                return false
            }
        })

        if persistentTokens.count > sortedIdentifiers.count {
            // If lost tokens were found and appended, save the full list of tokens
            saveTokenOrder()
        }
    }

    private func saveTokenOrder() {
        let persistentIdentifiers = persistentTokens.map { $0.identifier }
        userDefaults.savePersistentIdentifiers(persistentIdentifiers)
    }
}

extension KeychainTokenStore {
    // MARK: Actions

    func addToken(_ token: Token) throws {
        let newPersistentToken = try keychain.add(token)
        persistentTokens.append(newPersistentToken)
        saveTokenOrder()
    }

    func saveToken(_ token: Token, toPersistentToken persistentToken: PersistentToken) throws {
        let updatedPersistentToken = try keychain.update(persistentToken, with: token)
        // Update the in-memory token, which is still the origin of the table view's data
        persistentTokens = persistentTokens.map {
            if $0.identifier == updatedPersistentToken.identifier {
                return updatedPersistentToken
            }
            return $0
        }
    }

    func updatePersistentToken(_ persistentToken: PersistentToken) throws {
        let newToken = persistentToken.token.updatedToken()
        try saveToken(newToken, toPersistentToken: persistentToken)
    }

    func moveTokenFromIndex(_ origin: Int, toIndex destination: Int) {
        let persistentToken = persistentTokens[origin]
        persistentTokens.remove(at: origin)
        persistentTokens.insert(persistentToken, at: destination)
        saveTokenOrder()
    }

    func deletePersistentToken(_ persistentToken: PersistentToken) throws {
        try keychain.delete(persistentToken)
        if let index = persistentTokens.firstIndex(of: persistentToken) {
            persistentTokens.remove(at: index)
        }
        saveTokenOrder()
    }
}

// MARK: - Token Order Persistence

private let kOTPKeychainEntriesArray = "OTPKeychainEntries"

private extension UserDefaults {
    func persistentIdentifiers() -> [Data] {
        return array(forKey: kOTPKeychainEntriesArray) as? [Data] ?? []
    }

    func savePersistentIdentifiers(_ identifiers: [Data]) {
        set(identifiers, forKey: kOTPKeychainEntriesArray)
    }
}
