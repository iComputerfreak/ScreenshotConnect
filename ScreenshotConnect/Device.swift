//
//  Device.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 03.06.23.
//

import Foundation

public struct Device: Codable, Hashable {
    let name: String
    let screenshotDisplayType: ScreenshotDisplayType
}

extension [Device]: RawRepresentable {
    public var rawValue: String {
        guard
            let data = try? JSONEncoder().encode(self),
            let string = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return string
    }
    
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }
}
