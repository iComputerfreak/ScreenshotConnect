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
import CryptoKit

actor AppStoreConnectAPI: ObservableObject {
    private static let jsonDecoder = JSONDecoder()
    private static let jsonEncoder = JSONEncoder()
    private static let apiHost = "api.appstoreconnect.apple.com"
    
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
    
    // TODO: Add function to remove screenshot / all screenshots
    
    /// Fetches a list of all ``ACApp``s available on App Store Connect.
    /// - Returns: All existing ``ACApp``s
    func getApps() async throws -> [ACApp] {
        try await request(APIPath.apps, method: .get, as: ResultsWrapper<ACApp>.self).data
    }
    
    /// Fetches the app icon URL of the most recent app version.
    /// - Parameter appID: The app ID to fetch the app icon for
    /// - Returns: The URL referencing the app icon, or `nil`, if the most recent version does not have an app icon
    func getAppIcon(for appID: String) async throws -> URL? {
        try await request(APIPath.appBuilds(appID: appID), method: .get, as: ResultsWrapper<ACBuild>.self)
            .data
            .max(on: \.version, by: <)?
            .appIconURL
    }
    
    // TODO: Filter out versions for which we cannot upload screenshots anymore
    /// Fetches all existing app store versions of the given app ID.
    /// - Parameter appID: The app ID to fetch versions for
    /// - Returns: All existing app versions
    func getAppStoreVersions(for appID: String) async throws -> [ACAppStoreVersion] {
        try await request(APIPath.appStoreVersions(appID: appID), method: .get, as: ResultsWrapper<ACAppStoreVersion>.self)
            .data
            .sorted(on: \.creationDate, by: >)
    }
    
    /// Fetches all existing ``ACLocalization``s for the given app store version.
    /// - Parameter appStoreVersionID: The app store version ID to fetch localizations for
    /// - Returns: All existing ``ACLocalization``s of the given app store version ID
    func getLocalizations(for appStoreVersionID: String) async throws -> [ACLocalization] {
        try await request(
            APIPath.appStoreVersionLocalizations(appStoreVersionID: appStoreVersionID),
            method: .get,
            as: ResultsWrapper<ACLocalization>.self
        )
            .data
    }
    
    /// Fetches all existing ``ACAppScreenshotSet``s for the given localization.
    /// - Parameter localization: The localization for which to fetch the screenshot sets
    /// - Returns: All existing ``ACAppScreenshotSet``s matching the given localization
    func getScreenshotSets(for localization: ACLocalization) async throws -> [ACAppScreenshotSet] {
        var sets = try await request(
            APIPath.appScreenshotSets(localization: localization.id),
            method: .get,
            as: ResultsWrapper<ACAppScreenshotSet>.self
        )
        .data
        
        for i in 0..<sets.count {
            sets[i].locale = localization.locale
        }
        
        return sets
    }
    
    /// Creates a new ``ACAppScreenshotSet``.
    /// - Parameters:
    ///   - localization: The localization for which to create the screenshot set
    ///   - screenshotDisplayType: The display type for which to create the screenshot set
    /// - Returns: The created ``ACAppScreenshotSet``
    func createScreenshotSet(
        for localization: ACLocalization,
        screenshotDisplayType: ScreenshotDisplayType
    ) async throws -> ACAppScreenshotSet {
        let payload = CreateAppScreenshotSetPayload(
            screenshotDisplayType: screenshotDisplayType,
            localization: localization
        )
        // TODO: What if this produces an error (e.g. because a set already exists)
        var set = try await request(
            APIPath.appScreenshotSets,
            method: .post,
            as: SingleResultWrapper<ACAppScreenshotSet>.self,
            body: Self.jsonEncoder.encode(payload),
            contentType: .json
        ).data
        set.locale = localization.locale
        return set
    }
    
    /// Either returns an existing ``ACAppScreenshotSet`` or creates a new one.
    /// - Parameters:
    ///   - localization: The localization for which to fetch or create the screenshot set
    ///   - screenshotDisplayType: The display type for which to fetch or create the screenshot set
    /// - Returns: The ``ACAppScreenshotSet``
    func getOrCreateScreenshotSet(
        for localization: ACLocalization,
        screenshotDisplayType: ScreenshotDisplayType
    ) async throws -> ACAppScreenshotSet {
        // Check if a set already exists
        if
            let set = try await getScreenshotSets(for: localization)
                .first(where: { $0.screenshotDisplayType == screenshotDisplayType })
        {
            return set
        }
        // Create a new one
        return try await createScreenshotSet(for: localization, screenshotDisplayType: screenshotDisplayType)
    }
    
    func uploadScreenshots(
        _ screenshots: [AppScreenshot],
        to screenshotSet: ACAppScreenshotSet,
        onProgress: ((Int) -> Void)? = nil
    ) async throws {
        print("Uploading \(screenshots.count) screenshots")
        var uploadedCount = 0
        // Upload the screenshots alphabetically
        for screenshot in screenshots.sorted(on: \.fileName, by: <) {
            // Reserve the screenshot
            let reservation = try await reserve(screenshot, in: screenshotSet)
            let fileData = try Data(contentsOf: screenshot.url)
            try await uploadData(fileData, for: reservation)
            _ = try await commitUpload(of: screenshot, for: reservation.id)
            uploadedCount += 1
            onProgress?(uploadedCount)
        }
    }
    
    /// Reserves a screenshot on App Store Connect and requests upload operations to transmit it.
    /// - Parameters:
    ///   - appScreenshot: The screenshot to reserve on App Store Connect
    ///   - appScreenshotSet: The screenshot set where the screenshot is uploaded to
    /// - Returns: The reservation containing the upload operations used to upload the screenshot
    func reserve(
        _ appScreenshot: AppScreenshot,
        in appScreenshotSet: ACAppScreenshotSet
    ) async throws -> ACAppScreenshotReservation {
        let payload = CreateAppScreenshotReservationPayload(
            fileName: appScreenshot.fileName,
            fileSize: appScreenshot.fileSize,
            screenshotSetID: appScreenshotSet.id
        )
        return try await request(
            APIPath.appScreenshots,
            method: .post,
            as: SingleResultWrapper<ACAppScreenshotReservation>.self,
            body: Self.jsonEncoder.encode(payload),
            contentType: .json
        ).data
    }
    
    func deleteAppScreenshotSet(_ screenshotSetID: String) async throws {
        _ = try await requestData(APIPath.appScreenshotSets(id: screenshotSetID), method: .delete)
    }
    
    func uploadData(_ data: Data, for reservation: ACAppScreenshotReservation) async throws {
        for operation in reservation.uploadOperations {
            let start = operation.offset
            let end = start + operation.length - 1
            // The chunk to upload in this operation
            let chunk = data[start...end]
            // We don't care about the response data
            _ = try await requestData(
                url: operation.url,
                method: .put,
                body: chunk,
                contentType: .png
            )
        }
    }
    
    func commitUpload(of screenshot: AppScreenshot, for appScreenshotID: String) async throws -> ACAppScreenshotReservation {
        let fileData = try Data(contentsOf: screenshot.url)
        let md5 = Insecure.MD5.hash(data: fileData)
        let payload = CommitUploadPayload(
            appScreenshotID: appScreenshotID,
            sourceFileChecksum: md5.description
        )
        let result = try await request(
            APIPath.appScreenshots(for: appScreenshotID),
            method: .patch,
            as: SingleResultWrapper<ACAppScreenshotReservation>.self,
            body: Self.jsonEncoder.encode(payload),
            contentType: .json
        )
        return result.data
    }
}

// MARK: - Build URL

fileprivate extension AppStoreConnectAPI {
    func buildURL(for path: String) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.apiHost
        urlComponents.path = path
        // Don't append the queryItems, as that is done later
        guard let url = urlComponents.url else {
            throw Error.invalidURLComponents
        }
        return url
    }
}

// MARK: - Request and Decode
// Fetch and decode the request
fileprivate extension AppStoreConnectAPI {
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
    ) async throws -> ResponseType {
        try await request(
            url: buildURL(for: path),
            method: method,
            as: responseType,
            queryItems: queryItems,
            headers: headers,
            body: body,
            contentType: contentType
        )
    }
    
    private func request<ResponseType: Decodable>(
        url: URL,
        method: HTTPMethod,
        as responseType: ResponseType.Type,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: ContentType? = nil
    ) async throws -> ResponseType {
        let data = try await requestData(
            url: url,
            method: method,
            queryItems: queryItems,
            headers: headers,
            body: body,
            contentType: contentType
        )
        
        // Decode the response body (if there is any)
        guard !data.isEmpty else {
            throw Error.emptyResponseBody
        }
        // TODO: We need to detect if the response is instead an error and then throw that error
        return try Self.jsonDecoder.decode(ResponseType.self, from: data)
    }
}

// MARK: - Request Data
// Fetch the results, but don't decode them
fileprivate extension AppStoreConnectAPI {
    private func requestData(
        _ path: String,
        method: HTTPMethod,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: ContentType? = nil
    ) async throws -> Data {
        try await requestData(
            url: buildURL(for: path),
            method: method,
            queryItems: queryItems,
            headers: headers,
            body: body,
            contentType: contentType
        )
    }
    
    private func requestData(
        url: URL,
        method: HTTPMethod,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: ContentType? = nil
    ) async throws -> Data {
        // Append the query items
        var url = url
        if !queryItems.isEmpty {
            url.append(queryItems: queryItems.map(URLQueryItem.init(name:value:)))
        }
        
        // Configure the request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        try request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        if let contentType {
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        print("Making a \(method.rawValue.uppercased()) request to \(url.absoluteString)...")
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Handle any potential errors
        try checkForError(response: response, data: data)
        
        return data
    }
    
    // Checks if the response returned an error and throws the error
    // Returns normally otherwise
    private func checkForError(response: URLResponse, data: Data) throws {
        if let httpResponse = response as? HTTPURLResponse {
            // HTTP code should be in 2xx range
            if !(200...299 ~= httpResponse.statusCode) {
                try handleErrorResponse(for: httpResponse, data: data)
            }
        } else {
            print("Error: Response is not an HTTPURLResponse")
            print(response)
            throw Error.invalidResponse
        }
    }
    
    private func handleErrorResponse(for httpResponse: HTTPURLResponse, data: Data) throws {
        print("Error: HTTP response returned code \(httpResponse.statusCode)")
        // Try to decode the response as an error response
        if
            let errorResponse = try? Self.jsonDecoder.decode(ACErrorResponse.self, from: data),
            !errorResponse.errors.isEmpty
        {
            if errorResponse.errors.count > 1 {
                print("There are multiple errors in the response. Throwing the first one.")
                print("Errors:")
                errorResponse.errors.forEach { error in
                    print(error)
                }
            }
            throw errorResponse.errors.first!
        }
        let responseBody = String(data: data, encoding: .utf8)
        print(responseBody ?? "No response body.")
        // Fallback, if we were unable to decode the error
        throw Error.invalidStatusCode(statusCode: httpResponse.statusCode, response: responseBody)
    }
}
