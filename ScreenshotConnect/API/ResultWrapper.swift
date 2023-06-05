//
//  ResultWrapper.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation

struct ResultWrapper<Content>: Decodable where Content: Decodable {
    let data: [Content]
}
