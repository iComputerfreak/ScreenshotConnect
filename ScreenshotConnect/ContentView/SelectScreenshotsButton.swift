//
//  SelectScreenshotsButton.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectScreenshotsButton: View {
    let classifier = ScreenshotClassifier()
    
    @State private var showingScreenshotsImporter = false
    @Binding var screenshotsURL: URL?
    
    @Binding var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>]
    @Binding var selectedDevices: Set<Device>
    
    var body: some View {
        HStack {
            Button("Select Screenshots Folder") {
                self.showingScreenshotsImporter = true
            }
            Text(screenshotsURL?.path() ?? "No directory selected")
        }
        .fileImporter(isPresented: $showingScreenshotsImporter, allowedContentTypes: [.directory]) { result in
            do {
                let url = try result.get()
                DispatchQueue.main.async {
                    self.screenshotsURL = url
                }
                // MARK: Scan directory for screenshots
                do {
                    let results = try classifier.classifyScreenshots(in: url)
                    print("Classification results:")
                    print(results)
                    DispatchQueue.main.async {
                        self.classificationResults = results
                        self.selectedDevices = Set(classificationResults.compactMap(\.value?.device))
                    }
                } catch {
                    print(error)
                }
            } catch let error as ScreenshotClassifier.Error {
                print("Error classifying screenshots: \(error)")
            } catch {
                print("Error opening screenshots directory: \(error)")
            }
        }
    }
}

#Preview {
    SelectScreenshotsButton(screenshotsURL: .constant(nil), classificationResults: .constant([]), selectedDevices: .constant([]))
}
