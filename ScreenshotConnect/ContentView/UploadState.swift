//
//  UploadState.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 10.09.23.
//

import Foundation

enum UploadState {
    case idle
    case preparing
    case deletingExisting
    case uploadingScreenshots(current: Int, total: Int)
    case uploadSuccessful
    case error(Error)
    
    var localized: String {
        switch self {
        case .idle:
            return "Idle"
        case .preparing:
            return "Preparing upload..."
        case .deletingExisting:
            return "Deleting existing screenshots..."
        case .uploadingScreenshots:
            return "Uploading screenshots..."
        case .uploadSuccessful:
            return "Screenshots successfully uploaded"
        case .error(let error):
            return "Error during upload: \(error.localizedDescription)"
        }
    }
}
