//
//  ContentView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import SwiftUI

struct ContentView: View {
    @State var authenticationModel = AuthenticationModel()
    
    @State private var showAuthenticationPopup: Bool = false
    
    var body: some View {
        switch authenticationModel {
        case .none:
            AuthenticationInputView { newModel in
                authenticationModel = newModel
            }
        case .some(let token):
            Text("Logged in with \(token)")
        }
    }
}

#Preview {
    ContentView()
}
