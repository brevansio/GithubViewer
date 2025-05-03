//
//  SimpleUser.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

/// A further simplified version of the "SimpleUser" as defined by the Github REST API [here](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users)
///
/// Currently, only required items are read in from the data. When adding new items, please keep in mind the extra
/// overhead (in memory, processing, and especially, cognitive complexity).
struct SimpleUser: Codable, Identifiable {
    let icon: URL?
    let username: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case icon = "avatar_url"
        case username = "login"
        case id
    }
}

extension SimpleUser: Equatable {
    static func == (lhs: SimpleUser, rhs: SimpleUser) -> Bool {
        lhs.id == rhs.id
    }
}
