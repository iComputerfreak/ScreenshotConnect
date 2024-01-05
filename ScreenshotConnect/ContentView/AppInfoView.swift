//
//  AppInfoView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct AppInfoView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    @State private var appIconURL: URL? = nil
    
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
                Text(viewModel.selectedApp?.name ?? "Unknown")
                    .font(.title)
                Text(viewModel.selectedApp?.bundleID ?? "Unknown")
            }
        }
        // TODO: Change when on macOS 14
        .onAppear(perform: loadAppIcon)
        .onChange(of: viewModel.selectedApp, perform: { _ in loadAppIcon() })
    }
    
    func loadAppIcon() {
        print("App changed to \(viewModel.selectedApp?.name ?? "nil")")
        self.appIconURL = nil
        guard let appID = viewModel.selectedApp?.id else {
            print("Deselected an app")
            return
        }
        // Use two tasks to perform the two calls concurrently
        Task(priority: .userInitiated) {
            do {
                let url = try await viewModel.api.getAppIcon(for: appID)
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
