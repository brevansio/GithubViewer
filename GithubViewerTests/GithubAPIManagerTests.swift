//
//  GithubAPIManagerTests.swift
//  GithubAPIManagerTests
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation
import Testing

@testable import GithubViewer

// Note: These are for development. They will not run correctly as Unit Tests.
// To run, replace the `"abcd"` token with a real token, and run.
struct GithubAPIManagerTests {
    let apiManager = {
        let authentication = try! AuthenticationModel(token: "abcd")
        return GithubAPIManager(with: authentication)
    }()

    /*
    @Test
    func basicAuthentication() async throws {
        try await apiManager.basicAuthentication()
    }
    
    @Test
    func userList() async throws {
        let userList = try await apiManager.getUserList()
        #expect(!userList.users.isEmpty)
    }
    
    @Test
    func userDetails() async throws {
        let testUser = SimpleUser(icon: nil, username: "brevansio", id: 0)
    
        let user = try await apiManager.getUserDetails(for: testUser)
        #expect(user.username == "brevansio")
    }
    
    @Test
    func repositoryList() async throws {
        let testUser = SimpleUser(icon: nil, username: "brevansio", id: 0)
    
        let repositoryList = try await apiManager.getRepositories(for: testUser)
        #expect(!repositoryList.respositories.isEmpty)
    }
     */
}
