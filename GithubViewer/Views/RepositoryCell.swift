//
//  RepositoryCell.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct RepositoryCell: View {
    let repository: Repository
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.trianglehead.branch")
                .font(.title)
            VStack {
                Text(repository.name)
                    .font(.title2)
                Text(repository.description ?? "")
                    .font(.caption)
            }
            Spacer()
            VStack {
                Text(repository.language ?? "Unknown")
                    .font(.caption)
                Text("Stars: \(repository.stars)")
                    .font(.caption)
            }
            .layoutPriority(1)
        }
        .padding(.horizontal)
    }
}

#Preview {
    RepositoryCell(repository: Repository(id: 0, name: "Test/test", description: "A test Repo", url: URL(string: "https://github.com")!, language: "Swift", stars: 3, isForked: false))
}
