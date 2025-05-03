//
//  MockedAPIManager.swift
//  GithubViewerTests
//
//  Created by Bruce Evans on 2025/05/02.
//

#if DEBUG && targetEnvironment(simulator)
    import Foundation

    // TODO: Move this to somewhere more explicitly for testing. But keep in mind that Previews are the primary users.
    struct MockedAPIManager: APIManager {
        let uuid = UUID()

        func basicAuthentication() async throws {}

        func getUserList(from pageURL: URL? = nil) async throws -> (users: [SimpleUser], nextPage: URL?) {
            (
                [.init(icon: nil, username: "TestUser1", id: 1), .init(icon: nil, username: "TestUser2", id: 2)], nil
            )
        }

        func getUserDetails(for user: GithubViewer.SimpleUser) async throws -> GithubViewer.User {
            .init(icon: nil, username: "TestUser", fullname: "Test User", followerCount: 1, followingCount: 2)
        }

        func getRepositories(for user: SimpleUser, from pageURL: URL? = nil) async throws -> (
            respositories: [Repository], nextPage: URL?
        ) {
            (
                [
                    .init(
                        id: 1,
                        name: "testuser/testrepo",
                        description: "A test Repo",
                        url: URL(string: "https://github.com")!,
                        language: "Swift",
                        stars: 1,
                        isForked: false
                    ),
                    .init(
                        id: 2,
                        name: "testuser/testrepo2",
                        description: nil,
                        url: URL(string: "https://github.com")!,
                        language: "JavaScript",
                        stars: 0,
                        isForked: false
                    ),
                    .init(
                        id: 1,
                        name: "testuser/testrepo3",
                        description: nil,
                        url: URL(string: "https://github.com")!,
                        language: "Swift",
                        stars: 45,
                        isForked: true
                    ),
                ], nil
            )
        }

    }
#endif
