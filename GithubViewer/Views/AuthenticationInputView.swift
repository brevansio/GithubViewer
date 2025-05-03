//
//  AuthenticationInputView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/04/29.
//

import SwiftUI

struct AuthenticationInputView: View {
    @State private var token = ""
    @State private var validationStatus = ValidationStatus.invalid
    @State private var shouldShowError = false
    @State private var currentError: GithubViewerError? {
        didSet {
            shouldShowError = currentError != nil
            validationStatus = .invalid
        }
    }

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
        .alert(LocalizedStringKey("Authentication Failure"), isPresented: $shouldShowError) {
            Button(LocalizedStringKey("OK"), role: .cancel) {
                currentError = nil
            }
            if currentError?.isIgnorable == true {
                Button(LocalizedStringKey("Continue"), role: .destructive) {
                    let isFormatError = currentError as? AuthenticationError == .invalidFormat
                    let isPersistanceError = currentError as? AuthenticationError == .keychainFailure
                    currentError = nil
                    validationStatus = .validating
                    Task {
                        await validate(
                            token,
                            skipFormatErrors: isFormatError,
                            skipPersistanceErrors: isPersistanceError
                        )
                    }
                }
            }
        } message: {
            Text(currentError?.message ?? "Unknown Error")
        }

    }

    func validate(_ tokenString: String, skipFormatErrors: Bool = false, skipPersistanceErrors: Bool = false) async {
        validationStatus = .validating
        do {
            let authenticationToken = try AuthenticationModel(token: tokenString, ignoreFormatErrors: skipFormatErrors)
            let apiManager = GithubAPIManager(with: authenticationToken)
            try await apiManager.basicAuthentication()
            try authenticationToken.persist(igoreErrors: skipPersistanceErrors)
            validationStatus = .valid(apiManager)
        } catch {
            if let nonGenericError = error as? GithubViewerError {
                currentError = nonGenericError
            } else {
                currentError = UnknownError.unknown(error)
            }
        }
    }
}

#Preview {
    AuthenticationInputView { _ in }
}
