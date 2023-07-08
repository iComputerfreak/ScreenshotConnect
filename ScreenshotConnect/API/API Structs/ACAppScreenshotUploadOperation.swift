//
//  ACAppScreenshotUploadOperation.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 16.06.23.
//

import Foundation

struct ACAppScreenshotUploadOperation: Decodable {
    let url: URL
    let length: Int
    let offset: Int
    let requestHeaders: [ACRequestHeader]
}
