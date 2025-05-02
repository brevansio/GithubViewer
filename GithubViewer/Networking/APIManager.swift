//
//  APIManager.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/02.
//

import Foundation

enum NetworkError: Error {
    case authentication(status: Int)
    case server(status: Int)
    case genericConnection(status: Int)
    case invalidData
}

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

// Note: This only exists so we can mock and test the views without real-world API calls
protocol APIManager {
    var uuid: UUID { get }
    func basicAuthentication() async throws
    func getUserList() async throws -> [SimpleUser]
    func getUserDetails(for user: SimpleUser) async throws -> User
    func getRepositories(for user: SimpleUser) async throws -> [Repository]
}

// Note: Due to how `Equatable` works on Protocols, the above `ValidationStatus` won't compile since we are using
// `any APIManager` instead of `some APIManager`.
extension APIManager {
    func isEqual(to otherManager: APIManager) -> Bool {
        self.uuid == otherManager.uuid
    }
}
