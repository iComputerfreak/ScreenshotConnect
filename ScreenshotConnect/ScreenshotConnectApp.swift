//
//  ScreenshotConnectApp.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import SwiftUI

@main
struct ScreenshotConnectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppStoreConnectAPI())
        }
        Settings {
            SettingsView()
        }
    }
}
