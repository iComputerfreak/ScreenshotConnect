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
    
    enum DeliveryState: String, Decodable {
        case awaitingUpload = "AWAITING_UPLOAD"
        case uploadComplete = "UPLOAD_COMPLETE"
        case complete = "COMPLETE"
        case failed = "FAILED"
    }
}
