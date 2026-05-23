//
//  shii_macApp.swift
//  shii-mac
//
//  Created by codes on 5/22/26.
//

import SwiftUI

@main
struct shii_macApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
