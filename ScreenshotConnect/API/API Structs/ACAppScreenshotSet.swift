//
//  ACAppScreenshotSet.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import Foundation

struct ACAppScreenshotSet: Decodable, Hashable {
    let id: String
    let screenshotDisplayType: ScreenshotDisplayType
    var locale: String? = nil
    
    init(id: String, screenshotDisplayType: ScreenshotDisplayType, locale: String?) {
        self.id = id
        self.screenshotDisplayType = screenshotDisplayType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let attributes = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.screenshotDisplayType = try attributes.decode(ScreenshotDisplayType.self, forKey: .screenshotDisplayType)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case attributes
    }
    
    enum AttributeCodingKeys: CodingKey {
        case screenshotDisplayType
    }
}
