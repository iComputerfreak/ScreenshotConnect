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
    
    @State private var showingScreenshotsImporter = false
    @State private var screenshotsURL: URL?
    
    @State private var selectedApp: ACApp? = nil
    @State private var selectedAppVersion: String? = nil
    @State private var appIconURL: URL? = nil
    @State private var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>] = []
    @State private var selectedDevices: [(device: Device, isSelected: Bool)] = []
    
    var screenshotsByDevice: [Device: [AppScreenshot]] {
        // Only look at successes
        let successfulScreenshots = classificationResults
            .compactMap { result in
                result.value
            }
        
        return Dictionary(grouping: successfulScreenshots, by: \.device)
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
                HStack {
                    Button("Select Screenshots Folder") {
                        self.showingScreenshotsImporter = true
                    }
                    Text(screenshotsURL?.path() ?? "No directory selected")
                }
                .fileImporter(isPresented: $showingScreenshotsImporter, allowedContentTypes: [.directory]) { result in
                    if let url = result.value {
                        DispatchQueue.main.async {
                            self.screenshotsURL = url
                        }
                        // TODO: Scan directory
                    } else {
                        if let error = result.error {
                            print("Error opening screenshots directory: \(error)")
                        }
                    }
                }
                Text("Found \(0) screenshots. For \(0) languages.")
            }
            Section("Detected Devices") {
                List {
                    ForEach(Array(screenshotsByDevice.keys), id: \.name) { device in
                        let screenshotCount = screenshotsByDevice[device]?.count ?? 0
                        Toggle(sources: $selectedDevices, isOn: \.isSelected) {
                            HStack {
                                Text(device.name)
                                Spacer()
                                Text("\(screenshotCount) screenshots")
                            }
                        }
                    }
                }
            }
            Section("Select App") {
                Picker("Select an app", selection: $selectedApp.animation()) {
                    Text("Select an app...")
                        .tag(nil as ACApp?)
                    ForEach(apps.sorted(on: \.name, by: <), id: \.id) { app in
                        Text(app.name)
                            .tag(app as ACApp?)
                    }
                }
                if let app = selectedApp {
                    Picker("Select a version", selection: $selectedAppVersion) {
                        Text("Select a version...")
                            .tag(nil as String?)
                        ForEach(appVersions, id: \.self) { version in
                            Text(version)
                                .tag(version as String?)
                        }
                    }
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
            .onChange(of: selectedApp, perform: selectedAppChanged(to:))
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
    
    private func selectedAppChanged(to newValue: ACApp?) {
        print("App changed to \(newValue?.name ?? "nil")")
        self.appIconURL = nil
        self.appVersions = []
        guard let appID = newValue?.id else {
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
