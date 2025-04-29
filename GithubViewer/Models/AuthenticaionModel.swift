//
//  AuthenticaionModel.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation

struct AuthenticationModel {
    // Note: Using normal characters, so it won't fail
    static let tokenID = "io.brevans.gitviewer.token".data(using: .utf8)!
    
    let token: String
    
    init?(token: String? = nil) {
        if let token,
           !token.isEmpty,
           let tokenData = token.data(using: .utf8) {
            
            // TODO: Add Validation Logic
            // For now the above `if` should cover "basic" validation
            
            self.token = token
            
            let query = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: AuthenticationModel.tokenID,
                kSecValueData: tokenData
            ] as CFDictionary
            
            SecItemAdd(query, nil)  // FIXME: Validate the status. Low priority/risk here, but relates to UX
        } else {
            let query = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: AuthenticationModel.tokenID,
                kSecReturnData: true
            ] as CFDictionary
            
            var tokenDataReference: CFTypeRef?
            SecItemCopyMatching(query, &tokenDataReference) // FIXME: Validate the status. Low priority/risk here, but relates to UX
            
            guard let tokenData = tokenDataReference as? Data,
                  let token = String(data: tokenData, encoding: .utf8) else { return nil }
            
            self.token = token
        }
    }
}
