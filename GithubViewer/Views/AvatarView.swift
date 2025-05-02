//
//  AvatarView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SwiftUI

struct AvatarView: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) {
            $0.resizable()
        } placeholder: {
            Image(systemName: "person.circle").resizable()
        }
    }
}
