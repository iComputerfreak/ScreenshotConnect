//
//  ContentView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import SwiftUI
import JFUtils

struct ContentView: View {
    @EnvironmentObject private var api: AppStoreConnectAPI
    
    @State private var apps: [ACApp] = []
    @State private var screenshotsURL: URL?
    @State private var selectedApp: ACApp? = nil
    @State private var selectedAppVersion: String? = nil
    @State private var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>] = []
    @State private var selectedDevices: Set<Device> = []
    @State private var uploadedScreenshots: Int = 0
    
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
    
    var body: some View {
        Form {
            Section("Select Screenshots") {
                SelectScreenshotsButton(screenshotsURL: $screenshotsURL, classificationResults: $classificationResults, selectedDevices: $selectedDevices)
                if !screenshots.isEmpty {
                    Text("Found \(screenshots.count) screenshots for \(Set(screenshots.compactMap(\.locale)).count) locales.")
                }
                let missingLocaleCount = screenshots.filter({ $0.locale == nil }).count
                if missingLocaleCount > 0 {
                    Text("\(missingLocaleCount) screenshots don't have a locale. Please put them in subdirectories named after their locale (e.g. 'en-US')")
                }
            }
            Section("Detected Devices") {
                SelectDevicesList(classificationResults: $classificationResults, selectedDevices: $selectedDevices)
            }
            Section("Select App") {
                SelectAppPicker(apps: $apps, selectedApp: $selectedApp)
                if selectedApp != nil {
                    SelectVersionPicker(selectedApp: $selectedApp, selectedVersion: $selectedAppVersion)
                    AppInfoView(app: $selectedApp)
                        .animation(nil, value: selectedApp)
                }
            }
            VStack {
                HStack {
                    Spacer()
                    UploadButton()
                    Spacer()
                }
                ProgressView(value: Double(uploadedScreenshots), total: Double(screenshotsToUpload.count)) {
                    Text("Uploading screenshots...")
                } currentValueLabel: {
                    Text("\(uploadedScreenshots) / \(screenshotsToUpload.count)")
                }
            }
        }
        .formStyle(.grouped)
        .task {
            apps = (try? await api.getApps()) ?? []
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(height: 500)
    }
}
