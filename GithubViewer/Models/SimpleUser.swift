//
//  SimpleUser.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

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
