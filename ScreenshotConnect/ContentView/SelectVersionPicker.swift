//
//  SelectVersionPicker.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectVersionPicker: View {
    @Binding var versions: [String]
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
}

#Preview {
    SelectVersionPicker(versions: .constant(["1.2.0", "1.1.0", "1.0.0"]), selectedVersion: .constant("1.2.0"))
}
