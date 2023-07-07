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
    
    func upload(_ screenshots: [AppScreenshot], to app: ACApp, version: String) async throws {
        guard let version = try await api.getAppStoreVersions(for: app.id).first(where: \.version, equals: version) else {
            throw Error.unknownVersion
        }
        try await upload(screenshots, to: version)
    }
    
    func upload(_ screenshots: [AppScreenshot], to appStoreVersion: ACAppStoreVersion) async throws {
        let appStoreVersionID = appStoreVersion.id
        let localizations = try await api.getLocalizations(for: appStoreVersionID)
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
        
        // Each screenshot needs a screenshot set
        var screenshotSets: [ACAppScreenshotSet: [AppScreenshot]] = [:]
        
        // Upload the files alphabetically
        for screenshot in screenshots.sorted(on: \.fileName, by: <) {
            if let set = screenshotSets.keys.first(where: { set in
                set.screenshotDisplayType == screenshot.device.screenshotDisplayType &&
                set.locale == screenshot.locale
            }) {
                // We already have a matching set, append the screenshot
                screenshotSets[set]!.append(screenshot)
            } else {
                // Get or create the matching screenshot set
                let set = try await api.getOrCreateScreenshotSet(
                    for: localizations.first(where: { $0.locale == screenshot.locale })!,
                    screenshotDisplayType: screenshot.device.screenshotDisplayType
                )
                screenshotSets[set] = [screenshot]
            }
        }
        
        // At this point, we fetched the correct screenshot set for each screenshot
        
        for (set, screenshots) in screenshotSets {
            // Upload the screenshots as part of the set
            try await api.uploadScreenshots(screenshots, to: set)
        }
    }
    
    enum Error: Swift.Error {
        case screenshotMissingLocale
        case unknownLocale(locale: String)
        case unknownVersion
        case noAppSelected
        case noAppVersionSelected
    }
}
