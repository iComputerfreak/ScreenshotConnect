//
//  ACAppScreenshotReservation.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 16.06.23.
//

import Foundation

struct ACAppScreenshotReservation: Decodable {
    let id: String
    let fileName: String
    let fileSize: Int
    let uploadOperations: [ACAppScreenshotUploadOperation]
    let assetDeliveryState: ACAssetDeliveryState
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributeCodingKeys.self, forKey: .attributes)
        self.fileName = try attributesContainer.decode(String.self, forKey: .fileName)
        self.fileSize = try attributesContainer.decode(Int.self, forKey: .fileSize)
        self.uploadOperations = try attributesContainer.decode([ACAppScreenshotUploadOperation].self, forKey: .uploadOperations)
        self.assetDeliveryState = try attributesContainer.decode(ACAssetDeliveryState.self, forKey: .assetDeliveryState)
    }
    
    enum RootCodingKeys: CodingKey {
        case id
        case attributes
    }
    
    enum AttributeCodingKeys: CodingKey {
        case fileName
        case fileSize
        case uploadOperations
        case assetDeliveryState
    }
}
