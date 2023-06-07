//
//  File.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import Foundation

struct CreateAppScreenshotSetPayload: Encodable {
    let type = "appStoreVersionLocalizations"
    
    let screenshotDisplayType: ScreenshotDisplayType
    let localization: ACLocalization
    
    init(screenshotDisplayType: ScreenshotDisplayType, localization: ACLocalization) {
        self.screenshotDisplayType = screenshotDisplayType
        self.localization = localization
    }
    
    func encode(to encoder: Encoder) throws {
        var rootContainer = encoder.container(keyedBy: RootCodingKeys.self)
        var container = rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        var attributes = container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        try attributes.encode(screenshotDisplayType, forKey: .screenshotDisplayType)
        
        var relationships = container.nestedContainer(keyedBy: RelationshipCodingKeys.self, forKey: .relationships)
        try relationships.encode(localization.id, forKey: .id)
        try relationships.encode(type, forKey: .type)
    }
    
    enum RootCodingKeys: CodingKey {
        case data
    }
    
    enum CodingKeys: CodingKey {
        case attributes
        case relationships
    }
    
    enum AttributeCodingKeys: CodingKey {
        case screenshotDisplayType
    }
    
    enum RelationshipCodingKeys: CodingKey {
        case id
        case type
    }
}
