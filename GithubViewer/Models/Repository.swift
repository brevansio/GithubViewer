//
//  Repository.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let url: URL
    let language: String?
    let stars: Int
    let isForked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "full_name"
        case description
        case url = "html_url"
        case language
        case stars = "stargazers_count"
        case isForked = "fork"
    }
}
