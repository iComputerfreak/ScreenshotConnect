//
//  ScreenshotConnectApp.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import SwiftUI

@main
struct ScreenshotConnectApp: App {
    @Preference(\.issuerID) private var issuerID
    @Preference(\.privateKeyID) private var privateKeyID
    @Preference(\.privateKey) private var privateKey
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppStoreConnectAPI(
                    issuerID: issuerID,
                    privateKeyID: privateKeyID,
                    privateKey: privateKey
                ))
        }
        Settings {
            SettingsView()
        }
    }
}
