//
//  ACAppMediaStateError.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 16.06.23.
//

import Foundation

struct ACAppMediaStateError: LocalizedError, Decodable {
    let code: String
    let description: String
}
