//
//  ContentView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import SwiftUI
import JFUtils

class ContentViewModel: ObservableObject {
    @Published var apps: [ACApp] = []
    @Published var screenshotsURL: URL?
    @Published var selectedApp: ACApp?
    @Published var selectedAppVersion: ACAppStoreVersion?
    @Published var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>] = []
    @Published var selectedDevices: Set<Device> = []
    @Published var uploadedScreenshots: Int = 0
    @Published var versions: [ACAppStoreVersion] = []
    @Published var isUploading: Bool = false
    
    var screenshots: [AppScreenshot] {
        classificationResults.compactMap(\.value)
    }
    
    var classificationErrors: [ScreenshotClassifier.Error] {
        classificationResults
            .compactMap { result in
                result.error as? ScreenshotClassifier.Error
            }
    }
    
    var screenshotsToUpload: [AppScreenshot] {
        screenshots.filter { screenshot in
            selectedDevices.contains(screenshot.device)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var api: AppStoreConnectAPI
    
    @StateObject private var viewModel = ContentViewModel()
    
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
                if viewModel.isUploading {
                    ProgressView(value: Double(viewModel.uploadedScreenshots), total: Double(viewModel.screenshotsToUpload.count)) {
                        Text("Uploading screenshots...")
                    } currentValueLabel: {
                        Text("\(viewModel.uploadedScreenshots) / \(viewModel.screenshotsToUpload.count)")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .task {
            viewModel.apps = (try? await api.getApps()) ?? []
        }
        .padding()
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(height: 500)
    }
}
