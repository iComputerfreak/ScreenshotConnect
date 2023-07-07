//
//  ACAppStoreVersion.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 05.06.23.
//

import Foundation

struct ACAppStoreVersion: Decodable, Identifiable, Hashable {
    let id: String
    let platform: ACPlatform
    let version: String
    let state: ACAppStoreVersionState
    let creationDate: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let attributes = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.platform = try attributes.decode(ACPlatform.self, forKey: .platform)
        self.version = try attributes.decode(String.self, forKey: .version)
        self.state = try attributes.decode(ACAppStoreVersionState.self, forKey: .state)
        let dateString = try attributes.decode(String.self, forKey: .creationDate)
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            let context = DecodingError.Context(
                codingPath: [RootCodingKeys.attributes, AttributeCodingKeys.creationDate],
                debugDescription: "Date '\(dateString)' is not in ISO8601 format."
            )
            throw DecodingError.dataCorrupted(context)
        }
        self.creationDate = date
    }
    
    enum RootCodingKeys: String, CodingKey {
        case id
        case attributes
    }
    
    enum AttributeCodingKeys: String, CodingKey {
        case platform
        case version = "versionString"
        case state = "appStoreState"
        case creationDate = "createdDate"
    }
}
