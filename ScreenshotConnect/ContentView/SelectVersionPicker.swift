//
//  SelectVersionPicker.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectVersionPicker: View {
    @EnvironmentObject private var api: AppStoreConnectAPI
    @Binding var selectedApp: ACApp?
    @State private var versions: [String] = []
    @Binding var selectedVersion: String?
    
    var body: some View {
        Picker("Select a version", selection: $selectedVersion) {
            Text("Select a version...")
                .tag(nil as String?)
            ForEach(versions, id: \.self) { version in
                Text(version)
                    .tag(version as String?)
            }
        }
    }
    
    func loadVersions() {
        print("App changed to \(selectedApp?.name ?? "nil")")
        self.versions = []
        guard let appID = selectedApp?.id else {
            print("Deselected an app")
            return
        }
        Task(priority: .userInitiated) {
            do {
                let versions = try await api.getAppVersions(for: appID)
                await MainActor.run {
                    print("Setting appVersions to \(versions)")
                    self.versions = versions
                }
            } catch {
                print(error)
            }
        }
    }
}

//#Preview {
//    SelectVersionPicker(selectedApp: .constant(.preview), selectedVersion: .constant("1.2.0"))
//}
