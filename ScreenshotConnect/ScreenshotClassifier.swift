//
//  ScreenshotClassifier.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 03.06.23.
//

import Foundation
import UniformTypeIdentifiers

struct ScreenshotClassifier {
    
    enum Error: Swift.Error {
        case unknownDevice(URL)
        case unableToReadDirectory
    }
    
    @Preference(\.devices) private var devices
    
    /// Classifies all files in the given directory and its subdirectories.
    ///
    /// For a screenshot to successfully be classified, the device used for the screenshot and the file size needs to be available. Optionally, the locale will also be used.
    /// The function performs the following data extraction approaches:
    /// * The device is detected by comparing the filename and all parent directories with the names listed in the Settings of the app. The longest match will be used as the device
    /// * The file size is provided by the file system
    /// * The locale is detected from the name of the parent directory. If the parent directory represents a locale, the full parent directory name will be used.
    ///
    /// - Parameters:
    ///   - directory: The directory to search
    ///   - allowedFileTypes: The allowed file types to look at
    /// - Returns: A list of classification `Result`s containing either the successfully classified `AppScreenshot` or the `Error` that occured during classification.
    func classifyScreenshots(
        in directory: URL,
        allowedFileTypes: [UTType] = [.png]
    ) throws -> [Result<AppScreenshot, Error>] {
        let resourceKeys: Set<URLResourceKey> = [.nameKey, .isDirectoryKey, .fileSizeKey, .contentTypeKey]
        
        guard let directoryEnumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: .skipsHiddenFiles
        ) else {
            throw Error.unableToReadDirectory
        }
        
        var screenshots: [Result<AppScreenshot, Error>] = []
        for case let url as URL in directoryEnumerator {
            guard
                let resourceValues = try? url.resourceValues(forKeys: resourceKeys),
                let isDirectory = resourceValues.isDirectory,
                // We don't care about directories
                !isDirectory,
                let fileType = resourceValues.contentType,
                allowedFileTypes.contains(fileType)
            else {
                print("Skipping URL \(url.lastPathComponent), because it does not meet the requirements.")
                continue
            }
            
            // MARK: File Size
            guard let fileSize = resourceValues.fileSize else {
                print("Error reading file size of file \(url.lastPathComponent)")
                continue
            }
            
            // MARK: Device
            // We try to detect the device by comparing with our list of known devices
            guard
                let detectedDevice = devices
                    // We sort by name length to first check longer names (e.g. 'iPad Pro' before 'iPad')
                    .sorted(on: \.name.count, by: >)
                    .first(where: { device in
                        url.path(percentEncoded: false).contains(device.name)
                    })
            else {
                screenshots.append(.failure(Error.unknownDevice(url)))
                continue
            }
            
            // MARK: Locale
            // For the locale, we only look at the parent directory of the file itself
            var locale: String? = nil
            let regex = /[a-z]+(_|-)[a-z]+/
            if
                let parent = url.pathComponents.dropLast().last?.removingPercentEncoding,
                parent.lowercased().wholeMatch(of: regex) != nil
            {
                locale = parent
            }
            
            screenshots.append(.success(.init(url: url, device: detectedDevice, locale: locale, fileSize: fileSize)))
        }
        
        return screenshots
    }
}
