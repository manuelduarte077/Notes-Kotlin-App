//
//  ShareSheet.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// Share Sheet for Sharing PDF and Scanned Pages
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any?]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items.compactMap { $0 }, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
