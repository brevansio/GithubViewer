//
//  LoadingStatus.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import Foundation

enum LoadingStatus<T> {
    case loading
    case loaded(T)
    case failed
}
