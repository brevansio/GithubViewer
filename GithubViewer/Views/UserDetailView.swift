//
//  UserDetailView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SafariServices
import SwiftUI

struct UserDetailView: View {
    @Environment(\.apiManager) var apiManager
    
    let user: SimpleUser
    
    @State private var repositories: [Repository]?
    @State private var nextPage: URL?
    @State private var selectedRepository: Repository?
    
    var body: some View {
        VStack {
            UserCardView(user: user)
            Spacer()
            switch repositories {
            case .none:
                List {
                    ForEach(0..<5) { fakeId in
                        RepositoryCell(repository: Repository(id: fakeId, name: "Test/test", description: "A test Repo", url: URL(string: "https://github.com")!, language: "Swift", stars: 3, isForked: false))
                            .redacted(reason: .placeholder)
                    }
                }
                .onAppear {
                    Task {
                        await fetchRepositories()
                    }
                }
            case .some(let respositoryList):
                List(respositoryList) { repository in
                    Button {
                        selectedRepository = repository
                    } label: {
                        RepositoryCell(repository: repository)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if shouldLoadAdditionalRepositories(currentRepository: repository) {
                            let nextPageURL = nextPage
                            Task { await fetchRepositories(from: nextPageURL) }
                            nextPage = nil
                        }
                    }
                }
            }
        }
        .refreshable {
            repositories = nil
            nextPage = nil
            Task { await fetchRepositories() }
            
        }
        .fullScreenCover(item: $selectedRepository) { repository in
            SafariView(url: repository.url)
                .ignoresSafeArea()
                .transition(.move(edge: .trailing))
        }
    }
    
    private func fetchRepositories(from pageURL: URL? = nil) async {
        do {
            guard let results = try await apiManager?.getRepositories(for: user, from: pageURL) else {
                repositories = []
                return
            }
            
            repositories = (repositories ?? []) + results.respositories.filter { !$0.isForked }
            nextPage = results.nextPage
        } catch {
            print(error)
        }
    }
    
    private func shouldLoadAdditionalRepositories(currentRepository: Repository) -> Bool {
        guard nextPage != nil else { return false }
        guard let repositories else { return false }
        guard let currentIndex = repositories.lastIndex(where: { $0 == currentRepository }) else { return false }
        return currentIndex.distance(to: repositories.endIndex) < 5
    }
}

#Preview {
    UserDetailView(user: SimpleUser(icon: nil, username: "TestUser", id: 1))
        .environment(\.apiManager, MockedAPIManager())
}
