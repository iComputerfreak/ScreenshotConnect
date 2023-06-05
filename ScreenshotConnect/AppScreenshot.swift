//
//  AppScreenshot.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation
import SwiftUI

struct AppScreenshot {
    let url: URL
    let device: String // TODO: Custom enum
    let locale: String
    let fileSize: UInt64
    
    init(url: URL, device: String, locale: String) throws {
        self.url = url
        self.device = device
        self.locale = locale
        // Get file size
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path())
        self.fileSize = attributes[.size] as! UInt64
    }
}
