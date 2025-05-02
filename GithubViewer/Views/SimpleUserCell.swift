//
//  SimpleUserCell.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct SimpleUserCell: View {
    @State var user: SimpleUser
    
    var body: some View {
        HStack {
            AvatarView(url: user.icon)
                .frame(width: 44, height: 44)
                .cornerRadius(22)
            Text(user.username)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    SimpleUserCell(user: SimpleUser(icon: nil, username: "TestUser", id: 1))
}

