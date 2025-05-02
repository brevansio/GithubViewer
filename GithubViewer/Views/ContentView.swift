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
    @State var authenticationModel: AuthenticationModel? = try? AuthenticationModel()
    
    var body: some View {
        switch authenticationModel {
        case .none:
            AuthenticationInputView { newModel in
                authenticationModel = newModel
            }
        case .some(let token):
            NavigationView {
                UserListView(authenticationToken: token)
                    .navigationTitle("User List")
            }
        }
    }
}

#Preview {
    ContentView()
}
