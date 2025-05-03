//
//  GithubViewerError.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/03.
//

import Foundation

/// An ``Error`` abstraction that provides additional information on "known" errors to the UI
protocol GithubViewerError: Error {
    /// A user-facing message
    var message: String { get }

    /// If `true` ignoring this error should not cause a significant impact on the App
    var isIgnorable: Bool { get }
}

enum UnknownError: GithubViewerError {
    case unknown(Error)

    var message: String {
        switch self {
        case .unknown(let error):
            return "Unknown error: \(error)"
        }
    }

    var isIgnorable: Bool { false }
}
