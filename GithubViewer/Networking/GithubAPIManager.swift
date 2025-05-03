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
        case nextPage(URL)
        
        private static let baseEndpoint = URL(string: "https://api.github.com/")! // Note: Known URL

        var url: URL {
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
            case .nextPage(let pageURL):
                return pageURL
            }
            return APIEndpoints.baseEndpoint.appendingPathComponent(endpointExtention)
        }
    }
    
    private struct APIData {
        let data: Data
        let nextPage: URL?
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
    
    private func performRequest(to endpoint: URL) async throws -> APIData {
        let response = try await authenticatedSession.data(from: endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NetworkError.invalidData
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            // Get the next page from the link header
            guard let linkHeader = httpResponse.value(forHTTPHeaderField: "link"),
                  let nextRegex = try? Regex("<([^>]+)>; rel=\"[N,n]ext\""),   // Base Regex provided in Github Documentation
                  let nextPageURL = linkHeader.firstMatch(of: nextRegex)?.last?.substring else {
                return APIData(data: response.0, nextPage: nil)
            }
            return APIData(data: response.0, nextPage: URL(string: String(nextPageURL)))
        case 400..<500:
            throw NetworkError.authentication(status: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.server(status: httpResponse.statusCode)
        default:
            throw NetworkError.genericConnection(status: httpResponse.statusCode)
        }
    }
    
    func basicAuthentication() async throws {
        let _ = try await performRequest(to: APIEndpoints.authentication.url)
        return
    }
    
    func getUserList(from pageURL: URL? = nil) async throws -> (users: [SimpleUser], nextPage: URL?) {
        let endpoint: APIEndpoints
        if let pageURL {
            endpoint = .nextPage(pageURL)
        } else {
            endpoint = .userList
        }
        
        let responseData = try await performRequest(to: endpoint.url)
        let userList = try JSONDecoder().decode([SimpleUser].self, from: responseData.data)
        return (userList, responseData.nextPage)
    }
    
    func getUserDetails(for user: SimpleUser) async throws -> User {
        let responseData = try await performRequest(to: APIEndpoints.user(user.username).url)
        return try JSONDecoder().decode(User.self, from: responseData.data)
    }
    
    func getRepositories(for user: SimpleUser, from pageURL: URL? = nil) async throws -> (respositories: [Repository], nextPage: URL?) {
        let endpoint: APIEndpoints
        if let pageURL {
            endpoint = .nextPage(pageURL)
        } else {
            endpoint = .userList
        }
        
        let responseData = try await performRequest(to: APIEndpoints.repositoryList(user.username).url)
        let repositoryList = try JSONDecoder().decode([Repository].self, from: responseData.data)
        return (repositoryList, responseData.nextPage)
    }
}
