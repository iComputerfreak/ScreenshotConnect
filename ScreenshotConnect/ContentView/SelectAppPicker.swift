//
//  SelectAppPicker.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectAppPicker: View {
    @Binding var apps: [ACApp]
    @Binding var selectedApp: ACApp?
    
    var body: some View {
        Picker("Select an app", selection: $selectedApp.animation()) {
            Text("Select an app...")
                .tag(nil as ACApp?)
            ForEach(apps.sorted(on: \.name, by: <), id: \.id) { app in
                Text(app.name)
                    .tag(app as ACApp?)
            }
        }
    }
}

#Preview {
    SelectAppPicker(apps: .constant([ACApp.preview]), selectedApp: .constant(nil))
}
