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
    
    let onValidation: (APIManager?) -> Void
    
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
                case .valid(let apiManager):
                    ProgressView()
                        .padding()
                        .onAppear {
                            onValidation(apiManager)
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
            let apiManager = GithubAPIManager(with: authenticationToken)
            try await apiManager.basicAuthentication()
            try authenticationToken.persist()
            validationStatus = .valid(apiManager)
        } catch {
            // TODO: Show a specific error message
            validationStatus = .invalid
        }
    }
}

#Preview {
    AuthenticationInputView { _ in }
}
