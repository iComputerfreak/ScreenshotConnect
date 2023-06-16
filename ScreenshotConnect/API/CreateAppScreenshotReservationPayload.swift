//
//  CreateAppScreenshotReservationPayload.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 16.06.23.
//

import Foundation

struct CreateAppScreenshotReservationPayload: Encodable {
    let fileName: String
    let fileSize: Int
    let screenshotSetID: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        var attributesContainer = container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        try attributesContainer.encode(fileName, forKey: .fileName)
        try attributesContainer.encode(fileSize, forKey: .fileSize)
        
        var relationshipsContainer = container.nestedContainer(keyedBy: RelationshipsCodingKeys.self, forKey: .relationships)
        let set = SingleResultWrapper(data: AppScreenshotSet(id: screenshotSetID))
        try relationshipsContainer.encode(set, forKey: .appScreenshotSet)
    }
    
    enum RootCodingKeys: CodingKey {
        case attributes
        case relationships
        case type
    }
    
    enum AttributeCodingKeys: CodingKey {
        case fileName
        case fileSize
    }
    
    enum RelationshipsCodingKeys: CodingKey {
        case appScreenshotSet
    }
    
    struct AppScreenshotSet: Encodable {
        let id: String
        let type: String = "appScreenshotSets"
    }
}
