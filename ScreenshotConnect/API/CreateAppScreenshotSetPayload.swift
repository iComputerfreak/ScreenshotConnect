//
//  File.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import Foundation

struct CreateAppScreenshotSetPayload: Encodable {
    let type = "appScreenshotSets"
    let relationType = "appStoreVersionLocalizations"
    
    let screenshotDisplayType: ScreenshotDisplayType
    let localization: ACLocalization
    
    init(screenshotDisplayType: ScreenshotDisplayType, localization: ACLocalization) {
        self.screenshotDisplayType = screenshotDisplayType
        self.localization = localization
    }
    
    func encode(to encoder: Encoder) throws {
        var rootContainer = encoder.container(keyedBy: RootCodingKeys.self)
        var container = rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        try container.encode(type, forKey: .type)
        
        var attributes = container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        try attributes.encode(screenshotDisplayType, forKey: .screenshotDisplayType)
        
        var relationshipsContainer = container.nestedContainer(keyedBy: RelationshipsCodingKeys.self, forKey: .relationships)
        var rootLocalizationContainer = relationshipsContainer.nestedContainer(keyedBy: AppStoreVersionLocalizationRootCodingKeys.self, forKey: .appStoreVersionLocalization)
        var localizationContainer = rootLocalizationContainer.nestedContainer(keyedBy: AppStoreVersionLocalizationCodingKeys.self, forKey: .data)
        
        try localizationContainer.encode(localization.id, forKey: .id)
        try localizationContainer.encode(relationType, forKey: .type)
    }
    
    enum RootCodingKeys: CodingKey {
        case data
    }
    
    enum CodingKeys: CodingKey {
        case attributes
        case relationships
        case type
    }
    
    enum AttributeCodingKeys: CodingKey {
        case screenshotDisplayType
    }
    
    enum RelationshipsCodingKeys: CodingKey {
        case appStoreVersionLocalization
    }
    
    enum AppStoreVersionLocalizationRootCodingKeys: CodingKey {
        case data
    }
    
    enum AppStoreVersionLocalizationCodingKeys: CodingKey {
        case id
        case type
    }
}
