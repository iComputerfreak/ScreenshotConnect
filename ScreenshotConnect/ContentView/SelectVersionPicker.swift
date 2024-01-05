//
//  SelectVersionPicker.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectVersionPicker: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var body: some View {
        Picker("Select a version", selection: $viewModel.selectedAppVersion) {
            Text("Select a version...")
                .tag(nil as ACAppStoreVersion?)
            ForEach(viewModel.versions.sorted(on: \.version, by: <)) { version in
                Text(version.version)
                    .tag(version as ACAppStoreVersion?)
            }
        }
        // Load once on appear (initial app selected)
        .onAppear(perform: loadVersions)
        .onChange(of: viewModel.selectedApp) { _ in
            loadVersions()
        }
    }
    
    func loadVersions() {
        print("App changed to \(viewModel.selectedApp?.name ?? "nil")")
        self.viewModel.versions = []
        guard let appID = viewModel.selectedApp?.id else {
            print("Deselected an app")
            return
        }
        Task(priority: .userInitiated) {
            do {
                let versions = try await viewModel.api.getAppStoreVersions(for: appID)
                await MainActor.run {
                    print("Setting appVersions to \(versions.map(\.version))")
                    self.viewModel.versions = versions
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
