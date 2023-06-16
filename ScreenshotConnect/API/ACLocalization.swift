//
//  ACLocalization.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import Foundation

struct ACLocalization: Decodable {
    let id: String
    let locale: String
    
    init(id: String, locale: String) {
        self.id = id
        self.locale = locale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let attributes = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.locale = try attributes.decode(String.self, forKey: .locale)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case attributes
    }
    
    enum AttributeCodingKeys: CodingKey {
        case locale
    }
}
