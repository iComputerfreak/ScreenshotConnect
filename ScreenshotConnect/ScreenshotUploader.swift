//
//  ScreenshotUploader.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 01.06.23.
//

import Foundation
import AppStoreConnect_Swift_SDK

class ScreenshotUploader {
    private let configuration: APIConfiguration
    private lazy var provider: APIProvider = APIProvider(configuration: configuration)

    
    init(issuerID: String, privateKeyID: String, privateKey: String) {
        configuration = APIConfiguration(
            issuerID: issuerID,
            privateKeyID: privateKeyID,
            privateKey: privateKey
        )
    }
    
    // Classifies the given filenames and assigns them to devices; returns a dictionary containing the detected devices and the amount of files associated with it
    // Returns [Device: [URLs]]
    func classifyFilenames(_ filenames: [URL]) -> [String: [URL]] {
        return [:]
    }
    
    func upload(_ screenshots: [URL], to app: String) async throws {
        
    }
}
