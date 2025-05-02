//
//  UserListView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct UserListView: View {
    @Environment(\.apiManager) var apiManager

    @State private var status = LoadingStatus<[SimpleUser]>.loading
    
    var body: some View {
        switch status {
        case .loading:
            List {
                ForEach(0..<20) { fakeId in
                    SimpleUserCell(user: .init(icon: nil, username: "username", id: fakeId))
                        .redacted(reason: .placeholder)
                }
            }
            .onAppear {
                Task { await populateUsers() }
            }
        case .loaded(let users):
            List(users) { user in
                NavigationLink {
                    UserDetailView(user: user)
                } label: {
                    SimpleUserCell(user: user)
                }
            }
            // TODO: Add pagination and infinite scrolling
        case .failed:
            Text("Failed")
        }
    }
    
    private func populateUsers() async {
        guard let users = try? await apiManager?.getUserList() else {   // TODO: Losing the error is bad?
            status = .failed
            return
        }
        
        status = .loaded(users)
    }
}

#Preview {
    UserListView()
        .environment(\.apiManager, MockedAPIManager())
}
