//
//  AuthenticaionModel.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation

enum ValidationStatus: Equatable {
    case invalid
    case validating
    case valid(AuthenticationModel)
    
    static func == (lhs: ValidationStatus, rhs: ValidationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.invalid, .invalid), (.validating, .validating):
            return true
        case (.valid(let lhsToken), .valid(let rhsToken)):
            return lhsToken.token == rhsToken.token
        default:
            return false
        }
    }
}

struct AuthenticationModel: Sendable {
    // Note: Using normal characters, so it won't fail
    static let tokenID = "io.brevans.gitviewer.token".data(using: .utf8)!
    
    let token: String
    
    init?(token: String? = nil) {
        if let token,
           !token.isEmpty {
            // TODO: Add Validation Logic
            // For now the above `if` should cover "basic" validation
            self.token = token
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
    
    func persist() {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: AuthenticationModel.tokenID,
            kSecValueData: token.data(using: .utf8)!    // TODO: Clean up this IOU
        ] as CFDictionary
        
        SecItemAdd(query, nil)  // FIXME: Validate the status. Low priority/risk here, but relates to UX
    }
    
    static func clearExistingToken() {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: AuthenticationModel.tokenID
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
