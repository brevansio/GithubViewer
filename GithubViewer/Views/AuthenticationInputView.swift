//
//  AuthenticationInputView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import SwiftUI

struct AuthenticationInputView: View {
    @State var token = ""
    @State var validationStatus = ValidationStatus.invalid  // TODO: Show an error popup on _why_ it is invalid
    
    let onSubmit: (AuthenticationModel?) -> Void
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Image(systemName: "lock")
                        .foregroundStyle(.primary)
                    SecureField("Token", text: $token)
                        .disabled(validationStatus != .invalid)
                        .onSubmit {
                            Task {
                                await validate(token)
                            }
                        }
                        .foregroundStyle(.primary)
                }
                .padding([.top, .leading, .trailing])
                
                switch validationStatus {
                case .invalid:
                    Button {
                        Task {
                            await validate(token)
                        }
                    } label: {
                        Text("Validate")
                            .foregroundStyle(.primary)
                    }
                    .padding(.all)
                case .validating:
                    ProgressView()
                        .padding()
                case .valid(let authenticationToken):
                    Button {
                        onSubmit(authenticationToken)
                    } label: {
                        Text("Submit")
                    }
                }
            }
            .padding()
            .background(.separator)
            .cornerRadius(15)
            
            Spacer()
        }
    }
    
    func validate(_ tokenString: String) async {
        validationStatus = .validating
        do {
            let authenticationToken = try AuthenticationModel(token: tokenString)
            if try await GithubAPIManager.basicAuthentication(with: authenticationToken) {
                try authenticationToken.persist()
                validationStatus = .valid(authenticationToken)
            } else {
                validationStatus = .invalid // TODO: Show an error message
            }
        } catch {
            // TODO: Show a specific error message
            validationStatus = .invalid
        }
    }
}

#Preview {
    AuthenticationInputView { _ in }
}
