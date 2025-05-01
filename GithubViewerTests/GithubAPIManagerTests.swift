//
//  GithubAPIManagerTests.swift
//  GithubAPIManagerTests
//
//  Created by Bruce Evans on 2025/04/29.
//

@testable import GithubViewer
import Testing

struct GithubAPIManagerTests {

    @Test
    func basicAuthentication() async throws {
        let authentication = AuthenticationModel(token: "abcd")!
        
        let success = try await GithubAPIManager.basicAuthentication(with: authentication)
        #expect(success == false)
    }
    
    @Test
    func userList() async throws {
        let authentication = AuthenticationModel(token: "abcd")!
        
        let userList = try await GithubAPIManager.getUserList(with: authentication)
        #expect(userList == nil)
    }
}
