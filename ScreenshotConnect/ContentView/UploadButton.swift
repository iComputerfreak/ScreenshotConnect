//
//  UploadButton.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct UploadButton: View {
    var body: some View {
        Button {
            
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
