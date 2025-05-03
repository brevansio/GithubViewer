//
//  APIManager.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/02.
//

import Foundation

/// An ``Error`` abstraction for errors related to creating an ``APIManager``
enum NetworkError: GithubViewerError {
    case authentication(status: Int)
    case server(status: Int)
    case genericConnection(status: Int)
    case invalidData

    var message: String {
        switch self {
        case .authentication(let status):
            "Authentication failed with status code: \(status)"
        case .server(let status):
            "The server failed to handle the request with status code: \(status). Please wait a while and try again."
        case .genericConnection(let status):
            "There was a network failure with status code: \(status). Please wait a while and try again"
        case .invalidData:
            "The server responded with malformed data."
        }
    }

    var isIgnorable: Bool { false }
}

/// Describes the current usable state of an ``APIManager``
///
/// Used in UI
enum ValidationStatus: Equatable {  // TODO: Better naming?
    case invalid
    case validating
    case valid(APIManager)

    static func == (lhs: ValidationStatus, rhs: ValidationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.invalid, .invalid), (.validating, .validating):
            return true
        case (.valid(let lhsManager), .valid(let rhsManager)):
            return lhsManager.isEqual(to: rhsManager)
        default:
            return false
        }
    }
}

/// An interface for describing Github REST API calls
///
/// This only exists so we can mock and test the views without real-world API calls. Especially for Previews.
protocol APIManager {
    /// Used to test equality between two managers
    var uuid: UUID { get }
    
    /// Provides a simple test of whether or not the API is working correctly
    func basicAuthentication() async throws
    
    /// Returns a list of ``SimpleUser`` along with the ``URL`` for the next page of user results
    func getUserList(from pageURL: URL?) async throws -> (users: [SimpleUser], nextPage: URL?)
    
    /// As there is only a single ``User`` at a time, this does not require pagination
    func getUserDetails(for user: SimpleUser) async throws -> User
    
    /// Returns a list of ``Repository`` along with the ``URL`` for the next page of repository results
    func getRepositories(for user: SimpleUser, from pageURL: URL?) async throws -> (
        respositories: [Repository], nextPage: URL?
    )
}

extension APIManager {
    /// Compares two ``APIManager``s for equality
    ///
    ///  Due to how ``Equatable`` works on Protocols, the above ``ValidationStatus`` won't compile, even with
    ///  ``Equatable`` conformance since we are using `any APIManager` instead of `some APIManager`.
    func isEqual(to otherManager: APIManager) -> Bool {
        self.uuid == otherManager.uuid
    }
}
