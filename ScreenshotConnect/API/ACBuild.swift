//
//  ACBuild.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 03.06.23.
//

import Foundation

struct ACBuild: Decodable {
    let id: String
    let version: Int
    let appIconURL: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        let attributes = try container.nestedContainer(keyedBy: AttributeKeys.self, forKey: .attributes)
        let versionString = try attributes.decode(String.self, forKey: .version)
        guard let version = Int(versionString) else {
            let context = DecodingError.Context(
                codingPath: [RootKeys.attributes, AttributeKeys.version],
                debugDescription: "Stored string value '\(versionString)' is not convertible to Int."
            )
            throw DecodingError.typeMismatch(Int.self, context)
        }
        self.version = version
        
        let iconAsset = try attributes.nestedContainer(keyedBy: IconAssetKeys.self, forKey: .iconAssetToken)
        var urlString = try iconAsset.decode(String.self, forKey: .templateUrl)
        let width = try iconAsset.decode(Int.self, forKey: .width)
        let height = try iconAsset.decode(Int.self, forKey: .height)
        urlString = urlString.replacingOccurrences(of: "{w}", with: String(width))
        urlString = urlString.replacingOccurrences(of: "{h}", with: String(height))
        urlString = urlString.replacingOccurrences(of: "{f}", with: "png")
        guard let url = URL(string: urlString) else {
            let context = DecodingError.Context(
                codingPath: [RootKeys.attributes, AttributeKeys.iconAssetToken],
                debugDescription: "Unable to construct an URL from the given values."
            )
            throw DecodingError.dataCorrupted(context)
        }
        self.appIconURL = url
    }
    
    enum RootKeys: CodingKey {
        case id
        case attributes
    }
    
    enum AttributeKeys: CodingKey {
        case version
        case iconAssetToken
    }
    
    enum IconAssetKeys: CodingKey {
        case templateUrl
        case width
        case height
    }
}
