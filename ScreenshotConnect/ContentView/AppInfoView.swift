//
//  AppInfoView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct AppInfoView: View {
    @EnvironmentObject private var api: AppStoreConnectAPI
    @State private var appIconURL: URL? = nil
    @Binding var app: ACApp?
    
    var body: some View {
        HStack {
            // TODO: If there is no image, this view should not display a loading indicator indefinitely
            AsyncImage(url: appIconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
                    .padding()
            }
            .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(app?.name ?? "Unknown")
                    .font(.title)
                Text(app?.bundleID ?? "Unknown")
            }
        }
        // TODO: Change when on macOS 14
        .onAppear(perform: loadAppIcon)
        .onChange(of: app, perform: { _ in loadAppIcon() })
    }
    
    func loadAppIcon() {
        print("App changed to \(app?.name ?? "nil")")
        self.appIconURL = nil
        guard let appID = app?.id else {
            print("Deselected an app")
            return
        }
        // Use two tasks to perform the two calls concurrently
        Task(priority: .userInitiated) {
            do {
                let url = try await api.getAppIcon(for: appID)
                await MainActor.run {
                    print("Setting appIconURL to \(url?.absoluteString ?? "nil")")
                    self.appIconURL = url
                }
            } catch {
                print(error)
            }
        }
    }
}

//#Preview {
//    AppInfoView(app: .constant(.preview))
//}
