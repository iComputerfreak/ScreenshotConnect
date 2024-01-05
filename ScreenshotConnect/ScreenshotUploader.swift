//
//  ScreenshotUploader.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import Foundation
import AppStoreConnect_Swift_SDK

class ScreenshotUploader {
    let api: AppStoreConnectAPI
    
    init(api: AppStoreConnectAPI) {
        self.api = api
    }
    
    func upload(
        _ screenshots: [AppScreenshot],
        to app: ACApp,
        version: String,
        onProgress: ((UploadState) -> Void)? = nil
    ) async throws {
        guard let version = try await api.getAppStoreVersions(for: app.id).first(where: \.version, equals: version) else {
            throw Error.unknownVersion
        }
        try await upload(screenshots, to: version, onProgress: onProgress)
    }
    
    func upload(
        _ screenshots: [AppScreenshot],
        to appStoreVersion: ACAppStoreVersion,
        onProgress: ((UploadState) -> Void)? = nil
    ) async throws {
        onProgress?(.preparing)
        let appStoreVersionID = appStoreVersion.id
        let localizations = try await api.getLocalizations(for: appStoreVersionID)
        
        // MARK: Match Locales
        // We need to make sure that all given localizations exist on App Store Connect:
        let screenshotLocales = screenshots.compactMap(\.locale)
        let existingLocales = localizations.map(\.locale)
        guard !screenshots.contains(where: { $0.locale == nil }) else {
            throw Error.screenshotMissingLocale
        }
        for locale in screenshotLocales {
            guard existingLocales.contains(locale) else {
                throw Error.unknownLocale(locale: locale)
            }
        }
        
        // MARK: Fetch Existing Screenshots
        // Fetch all existing screenshot sets for the existing localizations
        var existingScreenshotSets: [ACAppScreenshotSet] = []
        for localization in localizations {
            let sets = try await api.getScreenshotSets(for: localization)
            existingScreenshotSets.append(contentsOf: sets)
        }
        
        // Each screenshot needs a screenshot set
        var screenshotSets: [ACAppScreenshotSet: [AppScreenshot]] = [:]
        
        onProgress?(.deletingExisting)
        // MARK: Assign Screenshots to Sets
        for screenshot in screenshots {
            if let set = screenshotSets.keys.first(where: { set in
                set.screenshotDisplayType == screenshot.device.screenshotDisplayType &&
                set.locale == screenshot.locale
            }) {
                // We already have a matching set, append the screenshot
                screenshotSets[set]!.append(screenshot)
            } else {
                // MARK: Delete Existing Screenshot Sets on AppStoreConnect
                // If there already exists a screenshot set
                if let index = existingScreenshotSets.firstIndex(where: { set in
                    set.screenshotDisplayType == screenshot.device.screenshotDisplayType &&
                    set.locale == screenshot.locale
                }) {
                    // Delete it
                    try await api.deleteAppScreenshotSet(existingScreenshotSets[index].id)
                    existingScreenshotSets.remove(at: index)
                }
                
                // Create a new screenshot set
                let set = try await api.createScreenshotSet(
                    for: localizations.first(where: { $0.locale == screenshot.locale })!,
                    screenshotDisplayType: screenshot.device.screenshotDisplayType
                )
                screenshotSets[set] = [screenshot]
            }
        }
        
        // At this point, we fetched the correct screenshot set for each screenshot
        print("Uploading \(screenshotSets.count) screenshot sets")
        onProgress?(.uploadingScreenshots(current: 1, total: screenshots.count))
        // The number of the screenshot we are currently trying to upload
        var currentScreenshot = 1
        for (set, setScreenshots) in screenshotSets {
            // Upload the screenshots as part of the set
            try await api.uploadScreenshots(setScreenshots, to: set) { _ in
                // Every time a screenshot is uploaded, increase the progress
                currentScreenshot += 1
                onProgress?(.uploadingScreenshots(current: currentScreenshot, total: screenshots.count))
            }
        }
        onProgress?(.uploadSuccessful)
    }
    
    enum Error: Swift.Error {
        case screenshotMissingLocale
        case unknownLocale(locale: String)
        case unknownVersion
        case noAppSelected
        case noAppVersionSelected
    }
}
