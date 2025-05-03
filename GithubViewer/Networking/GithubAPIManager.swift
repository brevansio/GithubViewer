//
//  GithubAPIManager.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation

/// A concrete implementation of ``APIManager``
struct GithubAPIManager: APIManager {
    /// An abstraction for dealing with Github REST API endpoints
    private enum APIEndpoints {
        case authentication
        case userList
        case user(String)
        case repositoryList(String)
        case nextPage(URL)

        /// The current Github REST API endpoint
        private static let baseEndpoint = URL(string: "https://api.github.com/")!  // Note: Known URL

        /// Maps values to the corresponding [REST API](https://docs.github.com/en/rest?apiVersion=2022-11-28) endpoint
        /// extensions
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

    /// A named `struct` for combining Network data and possible pagination data
    ///
    /// The Github REST API provides complete URLs for pagination rather than an offset we need to deal with
    private struct APIData {
        let data: Data
        let nextPage: URL?
    }

    let uuid = UUID()
    
    /// A session specifically configured for accessing the Github REST API with an API Token
    private let authenticatedSession: URLSession

    /// Sets up the ``authenticatedSession`` based on the provided token.
    ///
    /// There is no validation at this point.
    init(with authentication: AuthenticationModel) {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28",
        ]

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader

        authenticatedSession = URLSession(configuration: configuration)
    }

    /// Performs and parses a request to the given URL
    ///
    /// Assumes that the URL is a Github REST API endpoint. Other endpoints may fail.
    private func performRequest(to endpoint: URL) async throws -> APIData {
        let response = try await authenticatedSession.data(from: endpoint)
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NetworkError.invalidData
        }

        switch httpResponse.statusCode {
        case 200..<300:
            // Get the next page from the link header
            guard let linkHeader = httpResponse.value(forHTTPHeaderField: "link"),
                let nextRegex = try? Regex("<([^>]+)>; rel=\"[N,n]ext\""),  // Base Regex provided in Github Documentation
                let nextPageURL = linkHeader.firstMatch(of: nextRegex)?.last?.substring
            else {
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

    /// See ``APIManager.basicAuthentication()``
    func basicAuthentication() async throws {
        let _ = try await performRequest(to: APIEndpoints.authentication.url)
    }

    /// See ``APIManager.getUserList(from:)``
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

    /// See ``APIManager.getUserDetails(for:)``
    func getUserDetails(for user: SimpleUser) async throws -> User {
        let responseData = try await performRequest(to: APIEndpoints.user(user.username).url)
        return try JSONDecoder().decode(User.self, from: responseData.data)
    }

    /// See ``APIManager.getRepositories(for:from:)``
    func getRepositories(for user: SimpleUser, from pageURL: URL? = nil) async throws -> (
        respositories: [Repository], nextPage: URL?
    ) {
        let endpoint: APIEndpoints
        if let pageURL {
            endpoint = .nextPage(pageURL)
        } else {
            endpoint = .repositoryList(user.username)
        }

        let responseData = try await performRequest(to: endpoint.url)
        let repositoryList = try JSONDecoder().decode([Repository].self, from: responseData.data)
        return (repositoryList, responseData.nextPage)
    }
}
