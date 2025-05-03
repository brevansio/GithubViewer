//
//  Repository.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

/// A simplified version of the "MinimalRespository" as defined by the Github REST API [here](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user)
///
/// Currently, only required items are read in from the data. When adding new items, please keep in mind the extra
/// overhead (in memory, processing, and especially, cognitive complexity).
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

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }
}
