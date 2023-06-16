//
//  SingleResultWrapper.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 09.06.23.
//

import Foundation

struct SingleResultWrapper<Content> {
    let data: Content
}

extension SingleResultWrapper: Decodable where Content: Decodable {}
extension SingleResultWrapper: Encodable where Content: Encodable {}
