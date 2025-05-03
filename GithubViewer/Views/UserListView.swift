//
//  UserListView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct UserListView: View {
    @Environment(\.apiManager) var apiManager

    @State private var userList: [SimpleUser]?
    @State private var nextPage: URL?
    
    var body: some View {
        switch userList {
        case .none:
            List {
                ForEach(0..<20) { fakeId in
                    SimpleUserCell(user: .init(icon: nil, username: "username", id: fakeId))
                        .redacted(reason: .placeholder)
                }
            }
            .onAppear {
                Task { await populateUsers() }
            }
        case .some(let users):
            List(users) { user in
                NavigationLink {
                    UserDetailView(user: user)
                } label: {
                    SimpleUserCell(user: user)
                }
                .onAppear {
                    if shouldLoadAdditionalUsers(currentUser: user) {
                        let nextPageURL = nextPage
                        Task { await populateUsers(from: nextPageURL) }
                        nextPage = nil
                    }
                }
            }
            .refreshable {
                userList = nil
                nextPage = nil
                Task { await populateUsers() }
            }
        }
    }
    
    private func populateUsers(from pageURL: URL? = nil) async {
        do {
            guard let results = try await apiManager?.getUserList(from: pageURL) else {
                userList = []
                return
            }
            userList = (userList ?? []) + results.users
            nextPage = results.nextPage
        } catch {
            print(error)
        }
    }
    
    private func shouldLoadAdditionalUsers(currentUser: SimpleUser) -> Bool {
        guard nextPage != nil else { return false }
        guard let userList else { return false }
        guard let currentIndex = userList.lastIndex(where: { $0 == currentUser }) else { return false }
        return currentIndex.distance(to: userList.endIndex) < 5
    }
}

#Preview {
    UserListView()
        .environment(\.apiManager, MockedAPIManager())
}
