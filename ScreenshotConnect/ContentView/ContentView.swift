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
    @State private var appVersions: [String] = []
    
    @State private var screenshotsURL: URL?
    
    @State private var selectedApp: ACApp? = nil
    @State private var selectedAppVersion: String? = nil
    @State private var appIconURL: URL? = nil
    @State private var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>] = []
    @State private var selectedDevices: Set<Device> = []
    
    var screenshots: [AppScreenshot] {
        classificationResults.compactMap(\.value)
    }
    
    var classificationErrors: [ScreenshotClassifier.Error] {
        classificationResults
            .compactMap { result in
                result.error as? ScreenshotClassifier.Error
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
                if let app = selectedApp {
                    SelectVersionPicker(versions: $appVersions, selectedVersion: $selectedAppVersion)
                    HStack {
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
                            Text(app.name)
                                .font(.title)
                            Text(app.bundleID)
                        }
                    }
                    .animation(nil, value: selectedApp)
                }
            }
            .onChange(of: selectedApp, selectedAppChanged)
            Button("Reload") {
                Task(priority: .userInitiated) {
                    if let apps = try? await api.getApps() {
                        await MainActor.run {
                            self.apps = apps
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .task {
            apps = (try? await api.getApps()) ?? []
        }
        .padding()
    }
    
    private func selectedAppChanged() {
        print("App changed to \(selectedApp?.name ?? "nil")")
        self.appIconURL = nil
        self.appVersions = []
        guard let appID = selectedApp?.id else {
            print("Deselected an app")
            return
        }
        // Use two tasks to perform the two calls concurrently
        Task(priority: .userInitiated) {
            do {
                let url = try await api.getAppIcon(for: appID)
                await MainActor.run {
                    print("Setting appIconURL to \(url?.absoluteString ?? "nil")")
                    self.appIconURL = url
                }
            } catch {
                print(error)
            }
        }
        Task(priority: .userInitiated) {
            do {
                let versions = try await api.getAppVersions(for: appID)
                await MainActor.run {
                    print("Setting appVersions to \(versions)")
                    self.appVersions = versions
                }
            } catch {
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
