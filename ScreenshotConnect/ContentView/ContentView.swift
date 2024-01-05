//
//  ContentView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import SwiftUI
import JFUtils

struct ContentView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var showingError: Binding<Bool> {
        .init {
            viewModel.uploadError != nil
        } set: { newValue in
            // If we want to hide the error, set it to nil
            if newValue == false {
                viewModel.uploadState = .idle
            }
            // Showing the error by setting this binding to true is not supported.
            // We need an error to display
        }
    }
    
    var body: some View {
        Form {
            Section("Select Screenshots") {
                SelectScreenshotsButton()
                if !viewModel.screenshots.isEmpty {
                    Text("Found \(viewModel.screenshots.count) screenshots for \(Set(viewModel.screenshots.compactMap(\.locale)).count) locales.")
                }
                let missingLocaleCount = viewModel.screenshots.filter({ $0.locale == nil }).count
                if missingLocaleCount > 0 {
                    Text("\(missingLocaleCount) screenshots don't have a locale. Please put them in subdirectories named after their locale (e.g. 'en-US')")
                }
            }
            Section("Detected Devices") {
                SelectDevicesList()
            }
            Section("Select App") {
                SelectAppPicker()
                if viewModel.selectedApp != nil {
                    SelectVersionPicker()
                    AppInfoView()
                        .animation(nil, value: viewModel.selectedApp)
                }
            }
            VStack {
                HStack {
                    Spacer()
                    UploadButton()
                    Spacer()
                }
                UploadProgressView()
            }
        }
        .alert("Error", isPresented: showingError, presenting: viewModel.uploadError, actions: { error in
            if let acError = error as? ACErrorResponse.ACError {
                Text(acError.title).bold()
                Text(acError.detail)
            } else {
                Text(error.localizedDescription)
            }
        })
        .formStyle(.grouped)
        .task {
            await viewModel.fetchApps()
        }
        .padding()
        .environmentObject(viewModel)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .frame(height: 500)
//    }
//}
