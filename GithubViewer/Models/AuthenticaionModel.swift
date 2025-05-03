//
//  AuthenticaionModel.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation
import RegexBuilder

/// An ``Error`` abstraction for errors related to creating an ``AuthenticationModel``
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

    var isIgnorable: Bool {
        switch self {
        case .invalidFormat:
            true
        case .keychainFailure:
            true
        }
    }
}

/// Holds and persists Github Personal API tokens
///
/// Minimal Validation is applied
struct AuthenticationModel: Sendable {
    /// ID used for Keychain access
    static let tokenID = "io.brevans.gitviewer.token".data(using: .utf8)!

    /// Raw, (probably) verified token
    let token: String

    /// As there are multiple token formats, and there could be more in the future, it is possible to skip
    /// the formatting logic. Only do so with User consent.
    ///
    /// Calling with a `nil` token will attempt to read an existing token from the device Keychain.
    init(token: String? = nil, ignoreFormatErrors: Bool = false) throws {
        let regex = try Regex("^github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}$")
        let legacyRegex = try Regex("^ghp_[a-zA-Z0-9]{36,40}$")

        // If a token is not provided, we will attempt to retrieve one from the Keychain.
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

    /// Saves a token to the device Keychain
    ///
    /// While the format validation may be done in the ``init(token:ignoreFormatErrors:)`` function, this should be called after validating
    /// the acutal token itself, via a real API call.
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

    /// Removes a token from the device Keychain.
    ///
    /// This is designed to be used when the user's token expires, allowing them to re-enter a new token.
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
