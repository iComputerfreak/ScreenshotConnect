//
//  UploadButton.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct UploadButton: View {
    @EnvironmentObject private var api: AppStoreConnectAPI
    @Binding var selectedVersion: String
    
    var body: some View {
        Button {
            Task(priority: .high) {
                do {
                    let uploader = ScreenshotUploader(api: api)
                    // TODO: Upload
                } catch {
                    print(error)
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
