//
//  ContentViewModel.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 08.07.23.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    @Preference(\.issuerID) private var issuerID
    @Preference(\.privateKeyID) private var privateKeyID
    @Preference(\.privateKey) private var privateKey
    
    var api: AppStoreConnectAPI {
        AppStoreConnectAPI(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey)
    }
    
    @Published var apps: [ACApp] = []
    @Published var screenshotsURL: URL?
    @Published var selectedApp: ACApp?
    @Published var selectedAppVersion: ACAppStoreVersion?
    @Published var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>] = []
    @Published var selectedDevices: Set<Device> = []
    @Published var uploadState: UploadState = .idle
    @Published var versions: [ACAppStoreVersion] = []
    /// The current upload error, or nil if the upload is not errored
    var uploadError: Error? {
        if case let .error(error) = uploadState {
            return error
        }
        return nil
    }
    
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
    
    var isUploading: Bool {
        switch uploadState {
        case .preparing, .deletingExisting, .uploadingScreenshots:
            return true
        case .idle, .uploadSuccessful, .error:
            return false
        }
    }
    
    func fetchApps() async {
        print("Fetching apps...")
        do {
            self.apps = try await api.getApps()
        } catch {
            print("Error fetching apps: \(error)")
        }
        print("Fetched \(apps.count) apps.")
    }
}
