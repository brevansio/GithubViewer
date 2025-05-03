//
//  UserCardView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct UserCardView: View {
    @Environment(\.apiManager) var apiManager
    
    let user: SimpleUser
    
    @State private var status = LoadingStatus<User>.loading
    @State private var shouldShowError = false
    @State private var currentError: GithubViewerError? {
        didSet {
            shouldShowError = currentError != nil
            status = .failed
        }
    }
    
    var body: some View {
        HStack {
            AvatarView(url: user.icon)
                .frame(width: 66, height: 66)
                .cornerRadius(44)
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.title)
                switch status {
                case .loaded(let detailedUser):
                    Text(detailedUser.fullname ?? "")
                        .font(.headline)
                        .lineLimit(2)
                default:
                    Text("Status Message")
                        .font(.headline)
                        .redacted(reason: .placeholder)
                }
            }
            Spacer()
            HStack {
                switch status {
                case .loaded(let detailedUser):
                    FollowerView(followType: .following(detailedUser.followingCount))
                    Text("/")
                    FollowerView(followType: .followers(detailedUser.followerCount))
                default:
                    FollowerView(followType: .following(99))
                        .redacted(reason: .placeholder)
                    Text("/")
                    FollowerView(followType: .followers(99))
                        .redacted(reason: .placeholder)
                }
            }
            .layoutPriority(1)
        }
        .padding(.horizontal)
        .onAppear {
            Task {
                await getUserDetails()
            }
        }
        .alert(.init(stringLiteral: "Network Error"), isPresented: $shouldShowError) {
            Button("Retry") {
                currentError = nil
                status = .loading
                Task {
                    await getUserDetails()
                }
            }
            Button("Cancel", role: .cancel) {
                currentError = nil
            }
        } message: {
            Text(currentError?.message ?? "Unknown Error")
        }
    }
    
    private func getUserDetails() async {
        do {
            guard let details = try await apiManager?.getUserDetails(for: user) else {
                currentError = NetworkError.invalidData
                return
            }
            status = .loaded(details)
        } catch {
            if let knownError = error as? GithubViewerError {
                currentError = knownError
            } else {
                currentError = UnknownError.unknown(error)
            }
        }
    }
}

struct FollowerView: View {
    enum FollowType {
        case followers(UInt)
        case following(UInt)
        
        var title: String {
            switch self {
            case .followers:
                "Followers"
            case .following:
                "Following"
            }
        }
        
        var count: UInt {
            switch self {
            case .followers(let followerCount):
                followerCount
            case .following(let followingCount):
                followingCount
            }
        }
    }
    
    let followType: FollowType
    
    var body: some View {
        VStack {
            Text(followType.title)
            Text("\(followType.count)")
        }
        .font(.callout)
    }
}

#Preview {
    UserCardView(user: SimpleUser(icon: nil, username: "Test", id: 1))
        .environment(\.apiManager, MockedAPIManager())
}

