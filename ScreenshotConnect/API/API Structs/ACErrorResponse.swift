//
//  ACErrorResponse.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 20.07.23.
//

import Foundation

struct ACErrorResponse: Decodable {
    let errors: [ACError]
    
    enum CodingKeys: CodingKey {
        case errors
    }
    
    struct ACError: Swift.Error, Decodable, Identifiable {
        let code: String
        let status: String
        let id: String
        let title: String
        let detail: String
        
        enum CodingKeys: CodingKey {
            case code
            case status
            case title
            case detail
            case id
        }
    }
}
