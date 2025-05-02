//
//  SafariView.swift
//  GithubViewer
//
//  Created by Bruce Evans on 2025/05/01.
//

import WebKit
import SwiftUI

struct SafariView: UIViewRepresentable {
    let url: URL
        
    func makeUIView(context: Context) -> UIView {
        let webview = WKWebView()
        webview.load(URLRequest(url: url))
        return webview
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Nothing to do.
    }
}
