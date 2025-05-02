//
//  GithubAPIManager.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation

enum NetworkError: Error {
    case authentication(status: Int)
    case server(status: Int)
    case genericConnection(status: Int)
    case invalidData
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
    
    static func basicAuthentication(with authentication: AuthenticationModel) async throws {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        let authenticatedSession = URLSession(configuration: configuration)
        
        let response = try await authenticatedSession.data(from: APIEndpoints.authentication.endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NetworkError.invalidData
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 400..<500:
            throw NetworkError.authentication(status: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(status: httpResponse.statusCode)
        default:
            throw NetworkError.genericConnection(status: httpResponse.statusCode)
        }
    }
    
    static func getUserList(with authentication: AuthenticationModel) async throws -> [SimpleUser]? {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        let authenticatedSession = URLSession(configuration: configuration)
        
        let response = try await authenticatedSession.data(from: APIEndpoints.userList.endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            return nil
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try JSONDecoder().decode([SimpleUser].self, from: response.0)
        case 400..<500:
            throw NetworkError.authentication(status: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(status: httpResponse.statusCode)
        default:
            throw NetworkError.genericConnection(status: httpResponse.statusCode)
        }
        
        // TODO: Handle Pagination
    }
    
    static func getUserDetails(for user: SimpleUser, with authentication: AuthenticationModel) async throws -> User? {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        let authenticatedSession = URLSession(configuration: configuration)
        
        let response = try await authenticatedSession.data(from: APIEndpoints.user(user.username).endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            return nil
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try JSONDecoder().decode(User.self, from: response.0)
        case 400..<500:
            throw NetworkError.authentication(status: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(status: httpResponse.statusCode)
        default:
            throw NetworkError.genericConnection(status: httpResponse.statusCode)
        }
    }
    
    static func getRepositories(for user: SimpleUser, with authentication: AuthenticationModel) async throws -> [Repository]? {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        let authenticatedSession = URLSession(configuration: configuration)
        
        let response = try await authenticatedSession.data(from: APIEndpoints.repositoryList(user.username).endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            return nil
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try JSONDecoder().decode([Repository].self, from: response.0)
        case 400..<500:
            throw NetworkError.authentication(status: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(status: httpResponse.statusCode)
        default:
            throw NetworkError.genericConnection(status: httpResponse.statusCode)
        }
        
        // TODO: Handle Pagination
    }
}
