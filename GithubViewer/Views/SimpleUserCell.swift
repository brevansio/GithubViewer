//
//  SimpleUserCell.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct SimpleUserCell: View {
    private enum Design {
        /// The "recommended" size of a tappable item in the HIG
        static let avatarSize: CGFloat = 44
    }
    
    @State var user: SimpleUser?

    var body: some View {
        HStack {
            AvatarView(url: user?.icon)
                .frame(width: Design.avatarSize, height: Design.avatarSize)
                .cornerRadius(Design.avatarSize / 2)
            Text(user?.username ?? "Unknown")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    SimpleUserCell(user: SimpleUser(icon: nil, username: "TestUser", id: 1))
}
