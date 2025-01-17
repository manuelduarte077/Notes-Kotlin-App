//
//  DocScannerApp.swift
//  DocScanner
//
//  Created by Manuel Duarte on 28/06/24.
//

import SwiftUI

@main
struct DocScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Document.self)
    }
}
