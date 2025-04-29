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
    static let apiEndPoint = URL(string: "https://api.github.com/v3/")! // Note: Known URl
    
    static func basicAuthentication(with authentication: AuthenticationModel) async throws -> Bool {
        let authenticationHeader = [
            "Authentication": "BEARER \(authentication.token)",
            "X-Github-Api-Version": "2022-11-28"
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authenticationHeader
        
        let authenticatedSession = URLSession(configuration: configuration)
        
        let response = try await authenticatedSession.data(from: apiEndPoint)
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
