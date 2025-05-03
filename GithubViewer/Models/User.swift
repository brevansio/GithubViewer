//
//  SimpleUser.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

/// A simplified version of the "PrivateUser" defined by the Github REST API [here](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user-using-their-id)
///
/// Currently, only required items are read in from the data. When adding new items, please keep in mind the extra
/// overhead (in memory, processing, and especially, cognitive complexity).
struct User: Codable {
    let icon: URL?
    let username: String
    let fullname: String?
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
