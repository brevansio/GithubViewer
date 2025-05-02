//
//  GithubAPIManager.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation

struct GithubAPIManager: APIManager {
    private enum APIEndpoints {
        case authentication
        case userList
        case user(String)
        case repositoryList(String)
        
        private static let baseEndpoint = URL(string: "https://api.github.com/")! // Note: Known URL

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
    
    let uuid = UUID()
    private let authenticatedSession: URLSession
    
    init(with authentication: AuthenticationModel) {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        authenticatedSession = URLSession(configuration: configuration)
    }
    
    private func performRequest(to endpoint: URL) async throws -> Data {
        let response = try await authenticatedSession.data(from: endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NetworkError.invalidData
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return response.0
        case 400..<500:
            throw NetworkError.authentication(status: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(status: httpResponse.statusCode)
        default:
            throw NetworkError.genericConnection(status: httpResponse.statusCode)
        }
    }
    
    func basicAuthentication() async throws {
        let _ = try await performRequest(to: APIEndpoints.authentication.endpoint)
        return
    }
    
    func getUserList() async throws -> [SimpleUser] {
        let responseData = try await performRequest(to: APIEndpoints.userList.endpoint)
        return try JSONDecoder().decode([SimpleUser].self, from: responseData)
        
        // TODO: Handle Pagination
    }
    
    func getUserDetails(for user: SimpleUser) async throws -> User {
        let responseData = try await performRequest(to: APIEndpoints.user(user.username).endpoint)
        return try JSONDecoder().decode(User.self, from: responseData)
    }
    
    func getRepositories(for user: SimpleUser) async throws -> [Repository] {
        let responseData = try await performRequest(to: APIEndpoints.repositoryList(user.username).endpoint)
        return try JSONDecoder().decode([Repository].self, from: responseData)
        
        // TODO: Handle Pagination
    }
}
