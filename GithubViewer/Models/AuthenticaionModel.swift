//
//  AuthenticaionModel.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation
import RegexBuilder

enum AuthenticationError: Error {
    case invalidFormat
    case keychainFailure
}

struct AuthenticationModel: Sendable {
    // Note: Using normal characters, so it won't fail
    static let tokenID = "io.brevans.gitviewer.token".data(using: .utf8)!
    
    let token: String
    
    init(token: String? = nil) throws {
        let regex = try Regex("^github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}$")
        let legacyRegex = try Regex("^ghp_[a-zA-Z0-9]{36,40}$")
        
        if let token,
           !token.isEmpty {
            // TODO: Split the Regexes Apart. We can show a helpful message about upgrading the "Classic" tokens
            guard let _ = try regex.wholeMatch(in: token) ?? legacyRegex.wholeMatch(in: token) else {
                throw AuthenticationError.invalidFormat
            }
            self.token = token
        } else {
            let query = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: AuthenticationModel.tokenID,
                kSecReturnData: true
            ] as CFDictionary
            
            var tokenDataReference: CFTypeRef?
            guard SecItemCopyMatching(query, &tokenDataReference) == errSecSuccess else {
                throw AuthenticationError.keychainFailure
            }
            
            guard let tokenData = tokenDataReference as? Data,
                  let token = String(data: tokenData, encoding: .utf8) else { throw AuthenticationError.invalidFormat }
            
            guard let _ = try regex.wholeMatch(in: token) ?? legacyRegex.wholeMatch(in: token) else {
                throw AuthenticationError.invalidFormat
            }
            
            self.token = token
        }
    }
    
    func persist() throws {
        guard let tokenData = token.data(using: .utf8) else { throw AuthenticationError.invalidFormat }
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: AuthenticationModel.tokenID,
            kSecValueData: tokenData
        ] as CFDictionary
        
        if SecItemAdd(query, nil) != errSecSuccess {
            throw AuthenticationError.keychainFailure
        }
    }
    
    static func clearExistingToken() throws {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: AuthenticationModel.tokenID
        ] as CFDictionary
        
        if SecItemDelete(query) != errSecSuccess {
            throw AuthenticationError.keychainFailure
        }
    }
}
