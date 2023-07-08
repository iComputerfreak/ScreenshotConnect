//
//  ACRequestHeader.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 16.06.23.
//

import Foundation

struct ACRequestHeader: Decodable {
    let name: String
    let value: String
}
