//
//  UserDetailView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SafariServices
import SwiftUI

struct UserDetailView: View {
    let user: SimpleUser
    let token: AuthenticationModel
    
    @State var status = LoadingStatus<[Repository]>.loading
    @State var selectedRepository: Repository?
    
    var body: some View {
        UserCardView(user: user, token: token)
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
        guard let repositories = try? await GithubAPIManager.getRepositories(for: user, with: token) else {
            status = .failed
            return
        }
        
        status = .loaded(repositories)
    }
}

#Preview {
    UserDetailView(user: SimpleUser(icon: URL("https://avatars.githubusercontent.com/u/1?v=4")!, username: "mojombo", id: 1), token: try! AuthenticationModel(token: "abcd"))
}
