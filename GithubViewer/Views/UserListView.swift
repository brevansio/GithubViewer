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

    @State private var shouldShowError = false
    @State private var currentError: GithubViewerError? {
        didSet {
            shouldShowError = currentError != nil
        }
    }

    var body: some View {
        ZStack {
            if let userList {
                List(userList) { user in
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
            } else {
                List {
                    ForEach(0..<20) { fakeId in
                        SimpleUserCell(user: nil)
                            .redacted(reason: .placeholder)
                    }
                }
                .onAppear {
                    Task { await populateUsers() }
                }
            }
        }
        .refreshable {
            self.userList = nil
            nextPage = nil
            Task { await populateUsers() }
        }
        .alert(.init(stringLiteral: "Network Error"), isPresented: $shouldShowError) {
            if userList?.isEmpty ?? true {
                Button("Retry") {
                    currentError = nil
                    Task { await populateUsers() }
                }
            }
            Button("OK", role: .cancel) {
                currentError = nil
            }
        } message: {
            Text(currentError?.message ?? "Unknown Error")
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
            if let knownError = error as? GithubViewerError {
                currentError = knownError
            } else {
                currentError = UnknownError.unknown(error)
            }
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
        #if DEBUG && targetEnvironment(simulator)
            .environment(\.apiManager, MockedAPIManager())
        #endif
}
