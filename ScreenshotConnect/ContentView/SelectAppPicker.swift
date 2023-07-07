//
//  SelectAppPicker.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectAppPicker: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var body: some View {
        Picker("Select an app", selection: $viewModel.selectedApp.animation()) {
            Text("Select an app...")
                .tag(nil as ACApp?)
            ForEach(viewModel.apps.sorted(on: \.name, by: <), id: \.id) { app in
                Text(app.name)
                    .tag(app as ACApp?)
            }
        }
    }
}

//#Preview {
//    SelectAppPicker(apps: .constant([ACApp.preview]), selectedApp: .constant(nil))
//}
