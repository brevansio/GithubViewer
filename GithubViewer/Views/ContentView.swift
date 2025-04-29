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
            AuthenticationInputView { newModel in
                authenticationModel = newModel
            }
        case .some(let model):
            ProgressView()
                .foregroundStyle(.primary)
                .padding()
                .background(.tertiary)
                .cornerRadius(15)
        }
    }
}

#Preview {
    ContentView()
}
