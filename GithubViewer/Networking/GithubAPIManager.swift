//
//  GithubAPIManager.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation

enum NetworkError: Error {
    case authentication(status: Int)
}

enum GithubAPIManager {
    private enum APIEndpoints {
        case authentication
        case userList
        case user(String)
        case repositoryList(String)
        
        private static let baseEndpoint = URL(string: "https://api.github.com/")! // Note: Known URl

        var endpoint: URL {
            let endpointExtention: String
            switch self {
            case .authentication:
                endpointExtention = ""
            case .userList:
                endpointExtention = "users"
            case .user(let username):
                endpointExtention = "users/\(username)"
            case .repositoryList(let username):
                endpointExtention = "users/\(username)/repos"
            }
            return APIEndpoints.baseEndpoint.appendingPathComponent(endpointExtention)
        }
    }
    
    static func basicAuthentication(with authentication: AuthenticationModel) async throws -> Bool {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        let authenticatedSession = URLSession(configuration: configuration)
        
        let response = try await authenticatedSession.data(from: APIEndpoints.authentication.endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            return false
        }
        
        // TODO: Handle different codes as different issues. Especially 400 vs 500
        switch httpResponse.statusCode {
        case 200..<300:
            return true
        default:
            return false
        }
    }
}
