//
//  AuthenticationInputView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import SwiftUI

struct AuthenticationInputView: View {
    @State var token = ""
    
    let onSubmit: (AuthenticationModel?) -> Void
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Image(systemName: "lock")
                        .foregroundStyle(.primary)
                    SecureField("Token", text: $token)
                        .onSubmit {
                            onSubmit(AuthenticationModel(token: token))
                        }
                        .foregroundStyle(.primary)
                }
                .padding([.top, .leading, .trailing])
                
                Button {
                    onSubmit(AuthenticationModel(token: token))
                } label: {
                    Text("Submit")
                        .foregroundStyle(.primary)
                }
                .padding(.all)
            }
            .padding()
            .background(.separator)
            .cornerRadius(15)
            
            Spacer()
        }
    }
}

#Preview {
    AuthenticationInputView { _ in }
}
