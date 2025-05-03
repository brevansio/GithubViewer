//
//  SafariView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariController = SFSafariViewController(url: url)
        safariController.preferredBarTintColor = .systemBackground
        return safariController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Nothing to do
    }
}
