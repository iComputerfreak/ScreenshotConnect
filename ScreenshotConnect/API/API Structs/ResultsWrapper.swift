//
//  ResultsWrapper.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation

struct ResultsWrapper<Content> {
    let data: [Content]
}

extension ResultsWrapper: Decodable where Content: Decodable {}
extension ResultsWrapper: Encodable where Content: Encodable {}
