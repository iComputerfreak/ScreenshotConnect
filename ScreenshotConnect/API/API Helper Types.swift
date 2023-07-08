//
//  API Helper Types.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 08.07.23.
//

import Foundation
import SwiftJWT

extension AppStoreConnectAPI {
    enum APIPath {
        static let apps = "/v1/apps"
        static let appScreenshotSets = "/v1/appScreenshotSets"
        static func appScreenshotSets(id: String) -> String {
            appScreenshotSets + "/\(id)"
        }
        static func appScreenshotSets(localization localizationID: String) -> String {
            "/v1/appStoreVersionLocalizations/\(localizationID)/appScreenshotSets"
        }
        static func appBuilds(appID: String) -> String { "/v1/apps/\(appID)/builds" }
        static func appStoreVersions(appID: String) -> String { "/v1/apps/\(appID)/appStoreVersions" }
        static func appStoreVersionLocalizations(appStoreVersionID: String) -> String {
            "/v1/appStoreVersions/\(appStoreVersionID)/appStoreVersionLocalizations"
        }
        static let appScreenshots = "/v1/appScreenshots"
        static func appScreenshots(for appScreenshotID: String) -> String {
            appScreenshots + "/\(appScreenshotID)"
        }
    }
    
    enum ContentType: String {
        case png = "image/png"
        case json = "application/json"
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    enum Error: Swift.Error {
        case invalidURLComponents
        case invalidStatusCode(statusCode: Int, response: String?)
        case invalidResponse
        case emptyResponseBody
        case missingPrivateKey
    }
    
    struct JWTClaims: Claims {
        let iss: String
        let exp: Int
        let aud: String
    }
}
