//
//  ScreenshotConnectApp.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import SwiftUI

@main
struct ScreenshotConnectApp: App {
    @StateObject private var contentViewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentViewModel)
        }
        Settings {
            SettingsView()
                .environmentObject(contentViewModel)
        }
    }
}
