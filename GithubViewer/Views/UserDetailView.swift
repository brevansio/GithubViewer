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
    
    @State var status = LoadingStatus<[Repository]>.loading
    @State var selectedRepository: Repository?
    
    var body: some View {
        UserCardView(user: user)
        Spacer()
        List {
            switch status {
            case .loading:
                ProgressView()
                // TODO: PlaceHolder
            case .loaded(let respositoryList):
                ForEach(respositoryList) { repository in
                    Button {
                        selectedRepository = repository
                    } label: {
                        RepositoryCell(repository: repository)
                    }
                    .buttonStyle(.plain)
                }
            case .failed:
                Text("Failed")
            }
        }
        .onAppear {
            Task {
                await fetchRepositories()
            }
        }
        .fullScreenCover(item: $selectedRepository) { repository in
            SafariView(url: repository.url)
                .ignoresSafeArea()
                .transition(.move(edge: .trailing))
        }
    }
    
    private func fetchRepositories() async {
        guard let repositories = try? await apiManager?.getRepositories(for: user) else {
            status = .failed
            return
        }
        
        status = .loaded(repositories)
    }
}

#Preview {
    UserDetailView(user: SimpleUser(icon: nil, username: "TestUser", id: 1))
        .environment(\.apiManager, MockedAPIManager())
}
