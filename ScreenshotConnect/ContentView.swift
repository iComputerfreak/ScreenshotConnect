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
    
    @State private var showingScreenshotsImporter = false
    @State private var screenshotsURL: URL?
    
    @State private var selectedApp: ACApp? = nil
    @State private var appIconURL: URL? = nil
    
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
                    ForEach(["iPhone 11 Pro", "iPad Pro (6th Generation)"], id: \.self) { device in
                        Toggle(isOn: .constant(true)) {
                            HStack {
                                Text(device)
                                Spacer()
                                Text("\(Int.random(in: 0...10)) screenshots")
                            }
                        }
                    }
                }
            }
            Section("Select App") {
                Picker("Select an app", selection: $selectedApp) {
                    Text("Select an app...")
                        .tag(nil as ACApp?)
                    ForEach(apps.sorted(on: \.name, by: <), id: \.id) { app in
                        Text(app.name)
                            .tag(app as ACApp?)
                    }
                }
                Picker("Select a version", selection: .constant("2.2.0")) {
                    ForEach(["2.2.0", "2.3.0"], id: \.self) { version in
                        Text(version)
                    }
                }
                if let app = selectedApp {
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
                }
            }
            .onChange(of: selectedApp, perform: loadAppIcon(for:))
            Button("Reload") {
                Task(priority: .userInitiated) {
                    let api = AppStoreConnectAPI()
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
    
    private func loadAppIcon(for newValue: ACApp?) {
        print("App changed to \(newValue?.name ?? "nil")")
        self.appIconURL = nil
        guard let appID = newValue?.id else {
            print("Deselected an app")
            return
        }
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
