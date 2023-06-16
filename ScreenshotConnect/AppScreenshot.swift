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
    let device: Device
    let locale: String?
    let fileSize: Int
    
    var fileName: String {
        url.lastPathComponent
    }
    
    init(url: URL, device: Device, locale: String?, fileSize: Int) {
        self.url = url
        self.device = device
        self.locale = locale
        self.fileSize = fileSize
    }
}

extension AppScreenshot {
    static let preview = AppScreenshot(
        url: URL(string: "file:///Users/john/Desktop/Screenshot.png")!,
        device: .preview,
        locale: "en_US",
        fileSize: 4895
    )
}
