//
//  ResultWrapper.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation

struct ResultWrapper<Content> {
    let data: [Content]
}

extension ResultWrapper: Decodable where Content: Decodable {}
extension ResultWrapper: Encodable where Content: Encodable {}
