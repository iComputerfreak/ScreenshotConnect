//
//  ACAssetDeliveryState.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 16.06.23.
//

import Foundation

struct ACAssetDeliveryState: Decodable {
    let state: DeliveryState
    let warnings: [ACAppMediaStateError]
    let errors: [ACAppMediaStateError]
    
    enum CodingKeys: CodingKey {
        case state
        case warnings
        case errors
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(ACAssetDeliveryState.DeliveryState.self, forKey: .state)
        self.warnings = try container.decode([ACAppMediaStateError]?.self, forKey: .warnings) ?? []
        self.errors = try container.decode([ACAppMediaStateError]?.self, forKey: .errors) ?? []
    }
    
    enum DeliveryState: String, Decodable {
        case awaitingUpload = "AWAITING_UPLOAD"
        case uploadComplete = "UPLOAD_COMPLETE"
        case complete = "COMPLETE"
        case failed = "FAILED"
    }
}
