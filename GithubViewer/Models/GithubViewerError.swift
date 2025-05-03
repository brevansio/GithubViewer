//
//  GithubViewerError.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/03.
//

import Foundation

protocol GithubViewerError: Error {
    var message: String { get }
    var isRecoverable: Bool { get }
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
    
    var isRecoverable: Bool { false }
    var isIgnorable: Bool { false }
}
