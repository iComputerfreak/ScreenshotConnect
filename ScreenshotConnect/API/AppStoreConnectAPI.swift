//
//  AppStoreConnectAPI.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation
import SwiftJWT
import SwiftUI
import Combine

actor AppStoreConnectAPI: ObservableObject {
    private static let jsonDecoder = JSONDecoder()
    
    private var issuerID: String
    private var privateKeyID: String
    private var privateKey: Data
    
    private var signer: JWTSigner? {
        guard !privateKey.isEmpty else {
            return nil
        }
        return JWTSigner.es256(privateKey: privateKey)
    }
    
    private let lastTokenIssue: Date = .distantPast
    private let tokenValidity: TimeInterval
    private var _token: String?
    
    private var token: String {
        get throws {
            guard let signer else {
                throw Error.missingPrivateKey
            }
            // Create a new token, if the current one is nil or expired
            if _token == nil || lastTokenIssue + tokenValidity < .now {
                let header = Header(typ: "JWT", kid: privateKeyID)
                let claims = JWTClaims(
                    iss: issuerID,
                    exp: Int(Date(timeIntervalSinceNow: tokenValidity).timeIntervalSince1970),
                    aud: "appstoreconnect-v1"
                )
                var jwt = JWT(header: header, claims: claims)
                _token = try jwt.sign(using: signer)
            }
            return _token!
        }
    }
    
    init(issuerID: String, privateKeyID: String, privateKey: Data, tokenValidity: TimeInterval = 15 * 60) {
        self.tokenValidity = tokenValidity
        self.issuerID = issuerID
        self.privateKeyID = privateKeyID
        self.privateKey = privateKey
    }
    
    func getApps() async throws -> [ACApp] {
        guard let result = try await request(APIPath.apps, method: .get, as: ResultWrapper<ACApp>.self) else {
            // If we got an empty result, something went wrong
            throw Error.emptyResponseBody
        }
        return result.data
    }
    
    func getAppIcon(for appID: String) async throws -> URL? {
        return try await request(APIPath.appBuilds(appID: appID), method: .get, as: ResultWrapper<ACBuild>.self)?
            .data
            .max(on: \.version, by: <)?
            .appIconURL
    }
    
    // TODO: Filter out versions for which we cannot upload screenshots anymore
    func getAppVersions(for appID: String) async throws -> [String] {
        return try await request(APIPath.appStoreVersions(appID: appID), method: .get, as: ResultWrapper<ACStoreVersion>.self)?
            .data
            .sorted(on: \.creationDate, by: >)
            .map(\.version) ?? []
    }
    
    /// Executes an HTTP request to the App Store Connect API.
    ///
    ///     let result = try await request(.apps, method: .get, as: ResultWrapper<ACApp>.self)
    ///
    /// - Parameters:
    ///   - path: The API path to use for the request
    ///   - method: The HTTP method for the request
    ///   - responseType: The decodable type of the response body JSON. Usually this is some specialization of `ResultWrapper`.
    ///   - queryItems: The array of query items to append to the URL
    ///   - headers: The array of headers to specify for the request (in addition to the bearer token)
    ///   - body: The body of the request
    ///   - contentType: The content type of the body (will be appended as a header)
    /// - Returns: The decoded response body, or `nil`, if the response body is empty.
    private func request<ResponseType: Decodable>(
        _ path: String,
        method: HTTPMethod,
        as responseType: ResponseType.Type,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: ContentType? = nil
    ) async throws -> ResponseType? {
        // Build the URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.appstoreconnect.apple.com"
        urlComponents.path = path
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems.map(URLQueryItem.init(name:value:))
        }
        guard let url = urlComponents.url else {
            throw Error.invalidURLComponents
        }
        
        // Configure the request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        try request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        print("Making a request to \(url.absoluteString): \(request)")
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        let responseBody = String(data: data, encoding: .utf8)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                print("Error: HTTP response returned code \(httpResponse.statusCode)")
                throw Error.invalidStatusCode(httpResponse.statusCode, responseBody)
            }
        } else {
            print("Error: Response is not an HTTPURLResponse")
            print(response)
            throw Error.invalidResponse
        }
        
        // Decode the response body (if there is any)
        if !data.isEmpty {
            return try Self.jsonDecoder.decode(ResponseType.self, from: data)
        } else {
            return nil
        }
    }
}

extension AppStoreConnectAPI {
    enum APIPath {
        static let apps = "/v1/apps"
        static let appScreenshotSets = "/v1/appScreenshotSets"
        static func appBuilds(appID: String) -> String { "/v1/apps/\(appID)/builds" }
        static func appStoreVersions(appID: String) -> String { "/v1/apps/\(appID)/appStoreVersions" }
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
        case invalidStatusCode(Int, String?)
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
