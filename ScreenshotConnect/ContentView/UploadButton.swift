//
//  UploadButton.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct UploadButton: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var body: some View {
        Button {
            guard
                let selectedVersion = viewModel.selectedAppVersion
            else {
                assertionFailure("We should not have been able to press that button without a version selected")
                return
            }
            Task(priority: .high) {
                do {
                    let uploader = ScreenshotUploader(api: viewModel.api)
                    try await uploader.upload(viewModel.screenshotsToUpload, to: selectedVersion) { uploadState in
                        // When the progress changes, update the view model
                        DispatchQueue.main.async {
                            viewModel.uploadState = uploadState
                        }
                    }
                } catch {
                    print(error)
                    await MainActor.run {
                        viewModel.uploadState = .error(error)
                    }
                }
            }
        } label: {
            Text("Upload Screenshots")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Gradient(colors: [.blue, .blue.opacity(0.6)]))
                )
        }
        .buttonStyle(.borderless)
        .disabled(viewModel.selectedAppVersion == nil)
    }
}

//#Preview {
//    UploadButton()
//}

struct UploadButton_Previews: PreviewProvider {
    static var previews: some View {
        UploadButton()
            .padding()
    }
}
