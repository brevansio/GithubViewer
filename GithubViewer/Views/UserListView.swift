//
//  UserListView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct UserListView: View {
    let authenticationToken: AuthenticationModel

    @State private var status = LoadingStatus<[SimpleUser]>.loading
    
    var body: some View {
        switch status {
        case .loading:
            List {
                ForEach(0..<20) { fakeId in
                    SimpleUserCell(user: .init(icon: URL("https://google.com")!, username: "username", id: fakeId))
                        .redacted(reason: .placeholder)
                }
            }
            .onAppear {
                Task { await populateUsers() }
            }
        case .loaded(let users):
            List(users) { user in
                NavigationLink(destination: UserDetailView(user: user, token: authenticationToken)) {
                    SimpleUserCell(user: user)
                }
            }
            // TODO: Add pagination and infinite scrolling
        case .failed:
            Text("Failed")
        }
    }
    
    private func populateUsers() async {
        guard let users = try? await GithubAPIManager.getUserList(with: authenticationToken) else {
            status = .failed
            return
        }
        
        status = .loaded(users)
    }
}

#Preview {
    UserListView(authenticationToken: .init(token: "abdc")!)
}
