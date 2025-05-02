//
//  MockedAPIManager.swift
//  GithubViewerTests
//
//  Created by Bruce Evans on 2025/05/02.
//

#if DEBUG && targetEnvironment(simulator)
import Foundation

struct MockedAPIManager: APIManager {
    let uuid = UUID()
    
    func basicAuthentication() async throws {}
    
    func getUserList() async throws -> [GithubViewer.SimpleUser] {
        return [.init(icon: nil, username: "TestUser1", id: 1), .init(icon: nil, username: "TestUser2", id: 2)]
    }
    
    func getUserDetails(for user: GithubViewer.SimpleUser) async throws -> GithubViewer.User {
        return .init(icon: nil, username: "TestUser", fullname: "Test User", followerCount: 1, followingCount: 2)
    }
    
    func getRepositories(for user: GithubViewer.SimpleUser) async throws -> [GithubViewer.Repository] {
        return [
            .init(id: 1, name: "testuser/testrepo", description: "A test Repo", url: URL(string: "https://github.com")!, language: "Swift", stars: 1, isForked: false),
            .init(id: 2, name: "testuser/testrepo2", description: nil, url: URL(string: "https://github.com")!, language: "JavaScript", stars: 0, isForked: false),
            .init(id: 1, name: "testuser/testrepo3", description: nil, url: URL(string: "https://github.com")!, language: "Swift", stars: 45, isForked: true),
        ]
    }
    
    
}
#endif
