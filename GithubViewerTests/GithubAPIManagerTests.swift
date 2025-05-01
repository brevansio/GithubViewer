//
//  GithubAPIManagerTests.swift
//  GithubAPIManagerTests
//
//  Created by Bruce Evans on 2025/04/29.
//

import Foundation
@testable import GithubViewer
import Testing

struct GithubAPIManagerTests {

    @Test
    func basicAuthentication() async throws {
        let authentication = AuthenticationModel(token: "abcd")!
        
        let success = try await GithubAPIManager.basicAuthentication(with: authentication)
        #expect(success != false)
    }
    
    @Test
    func userList() async throws {
        let authentication = AuthenticationModel(token: "abcd")!
        
        let userList = try await GithubAPIManager.getUserList(with: authentication)
        #expect(userList != nil)
    }
    
    @Test
    func userDetails() async throws {
        let authentication = AuthenticationModel(token: "abcd")!
        let testUser = SimpleUser(icon: URL("https://google.com")!, username: "brevansio", id: 0)
        
        let user = try await GithubAPIManager.getUserDetails(for: testUser, with: authentication)
        #expect(user != nil)
    }
    
    @Test
    func repositoryList() async throws {
        let authentication = AuthenticationModel(token: "abcd")!
        let testUser = SimpleUser(icon: URL("https://google.com")!, username: "brevansio", id: 0)
        
        let repositoryList = try await GithubAPIManager.getRepositories(for: testUser, with: authentication)
        #expect(repositoryList != nil)
    }
    
}
