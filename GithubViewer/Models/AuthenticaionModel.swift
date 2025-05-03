//
//  AuthenticaionModel.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation
import RegexBuilder

enum AuthenticationError: GithubViewerError {
    case invalidFormat
    case keychainFailure

    var message: String {
        switch self {
        case .invalidFormat:
            "The token does not appear to be in the correct format. Please use Github Private API Tokens."
        case .keychainFailure:
            "Failed to save the token to the keychain. Continue without saving?\nNote: The app will continue to work, but you will need to reenter your token next time you launch the app."
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .invalidFormat:
            true
        case .keychainFailure:
            false
        }
    }

    var isIgnorable: Bool {
        switch self {
        case .invalidFormat:
            true
        case .keychainFailure:
            true
        }
    }
}

struct AuthenticationModel: Sendable {
    // Note: Using normal characters, so it won't fail
    static let tokenID = "io.brevans.gitviewer.token".data(using: .utf8)!

    let token: String

    init(token: String? = nil, ignoreFormatErrors: Bool = false) throws {
        let regex = try Regex("^github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}$")
        let legacyRegex = try Regex("^ghp_[a-zA-Z0-9]{36,40}$")

        if let token,
            !token.isEmpty
        {

            // Allow the user to skip formatting errors. This could be helpful if the API Token is in a legitimate,
            // but unknown format.
            if !ignoreFormatErrors {
                // TODO: Split the Regexes Apart. We can show a helpful message about upgrading the "Classic" tokens
                guard (try regex.wholeMatch(in: token) ?? legacyRegex.wholeMatch(in: token)) != nil else {
                    throw AuthenticationError.invalidFormat
                }
            }

            self.token = token
        } else {
            let query =
                [
                    kSecClass: kSecClassKey,
                    kSecAttrApplicationTag: AuthenticationModel.tokenID,
                    kSecReturnData: true,
                ] as CFDictionary

            var tokenDataReference: CFTypeRef?
            guard SecItemCopyMatching(query, &tokenDataReference) == errSecSuccess else {
                throw AuthenticationError.keychainFailure
            }

            guard let tokenData = tokenDataReference as? Data,
                let token = String(data: tokenData, encoding: .utf8)
            else { throw AuthenticationError.invalidFormat }

            guard (try regex.wholeMatch(in: token) ?? legacyRegex.wholeMatch(in: token)) != nil else {
                throw AuthenticationError.invalidFormat
            }

            self.token = token
        }
    }

    func persist(igoreErrors: Bool = false) throws {
        guard let tokenData = token.data(using: .utf8) else { throw AuthenticationError.invalidFormat }
        let query =
            [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: AuthenticationModel.tokenID,
                kSecValueData: tokenData,
            ] as CFDictionary

        if SecItemAdd(query, nil) != errSecSuccess {
            if !igoreErrors {
                throw AuthenticationError.keychainFailure
            }
        }
    }

    static func clearExistingToken() throws {
        let query =
            [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: AuthenticationModel.tokenID,
            ] as CFDictionary

        if SecItemDelete(query) != errSecSuccess {
            throw AuthenticationError.keychainFailure
        }
    }
}
