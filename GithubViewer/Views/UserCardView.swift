//
//  UserCardView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct UserCardView: View {
    let user: SimpleUser
    let token: AuthenticationModel
    
    @State private var status = LoadingStatus<User>.loading
    
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
                    Text(detailedUser.fullname)
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
    }
    
    private func getUserDetails() async {
        guard let details = try? await GithubAPIManager.getUserDetails(for: user, with: token) else {
            status = .failed
            return
        }
        status = .loaded(details)
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
    UserCardView(user: SimpleUser(icon: URL("https://avatars.githubusercontent.com/u/1?v=4")!, username: "mojombo", id: 1), token: try! AuthenticationModel(token: "abcd"))
}

