//
//  ContentView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import SwiftUI

struct ContentView: View {
    @State var authenticationModel = AuthenticationModel()
    
    var body: some View {
        switch authenticationModel {
        case .none:
            Text("Not Logged in")
        case .some(let token):
            Text("Logged in")
        }
    }
}

#Preview {
    ContentView()
}
