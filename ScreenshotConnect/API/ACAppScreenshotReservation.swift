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
}
