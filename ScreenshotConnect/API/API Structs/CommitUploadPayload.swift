//
//  CommitUploadPayload.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.07.23.
//

import Foundation

// TODO: Encode into data container instead of using ResultWrapper

struct CommitUploadPayload: Encodable {
    let type = "appScreenshots"
    let appScreenshotID: String
    let uploaded: Bool = true
    let sourceFileChecksum: String
    
    func encode(to encoder: Encoder) throws {
        var rootContainer = encoder.container(keyedBy: RootCodingKeys.self)
        var container = rootContainer.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data)
        try container.encode(type, forKey: .type)
        try container.encode(appScreenshotID, forKey: .id)
        var attributesContainer = container.nestedContainer(keyedBy: AttributesCodingKey.self, forKey: .attributes)
        try attributesContainer.encode(uploaded, forKey: .uploaded)
        try attributesContainer.encode(sourceFileChecksum, forKey: .sourceFileChecksum)
    }
    
    enum RootCodingKeys: CodingKey {
        case data
    }
    
    enum DataCodingKeys: CodingKey {
        case type
        case id
        case attributes
    }
    
    enum AttributesCodingKey: CodingKey {
        case uploaded
        case sourceFileChecksum
    }
}
