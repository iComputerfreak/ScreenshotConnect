//
//  App.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation

struct ACApp: Decodable, Equatable, Hashable {
    let id: String
    let name: String
    let bundleID: String
    let sku: String
    let primaryLocale: String
    
    init(id: String, name: String, bundleID: String, sku: String, primaryLocale: String) {
        self.id = id
        self.name = name
        self.bundleID = bundleID
        self.sku = sku
        self.primaryLocale = primaryLocale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        self.name = try attributesContainer.decode(String.self, forKey: .name)
        self.bundleID = try attributesContainer.decode(String.self, forKey: .bundleID)
        self.sku = try attributesContainer.decode(String.self, forKey: .sku)
        self.primaryLocale = try attributesContainer.decode(String.self, forKey: .primaryLocale)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case name
        case bundleID = "bundleId"
        case sku
        case primaryLocale
    }
}

extension ACApp {
    static let preview = ACApp(
        id: "6449793212",
        name: "Movie DB",
        bundleID: "de.JonasFrey.Movie-DB",
        sku: "de.JonasFrey.Movie-DB",
        primaryLocale: "de_DE"
    )
}
