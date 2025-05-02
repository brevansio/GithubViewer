//
//  ContentView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import SwiftUI



struct ContentView: View {
    // Note: It's probably ok to ignore the error here. It would mean that we can't read from the keychain, so
    // we need to re-enter anyway. That already happens in this view.
    @State var apiManager: APIManager? = {
        guard let authenticationModel = try? AuthenticationModel() else { return nil }
        return GithubAPIManager(with: authenticationModel)
    }()
    
    var body: some View {
        switch apiManager {
        case .none:
            AuthenticationInputView { apiManager in
                self.apiManager = apiManager
            }
        case .some(let manager):
            NavigationView {
                UserListView()
                    .navigationTitle("User List")
            }
            .environment(\.apiManager, manager)
        }
    }
}

#Preview {
    ContentView()
}
