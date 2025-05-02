//
//  EnvironmentValues+APIManagerKey.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/02.
//

import SwiftUI

extension EnvironmentValues {
    private enum APIManagerKey: EnvironmentKey {
        static let defaultValue: APIManager? = nil
    }
    var apiManager: APIManager? {
        get { self[APIManagerKey.self] }
        set { self[APIManagerKey.self] = newValue }
    }
}
