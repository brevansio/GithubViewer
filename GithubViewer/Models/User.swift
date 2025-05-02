//
//  SimpleUser.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

struct User: Codable {
    let icon: URL?
    let username: String
    let fullname: String
    let followerCount: UInt
    let followingCount: UInt
    
    enum CodingKeys: String, CodingKey {
        case icon = "avatar_url"
        case username = "login"
        case fullname = "name"
        case followerCount = "followers"
        case followingCount = "following"
    }
}
