//
//  SettingsView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 02.06.23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers.UTType

struct SettingsView: View {
    @Preference(\.issuerID) private var issuerID
    @Preference(\.privateKeyID) private var privateKeyID
    // TODO: Store encrypted
    @Preference(\.privateKey) private var privateKey
    
    @Preference(\.devices) private var devices
    
    @EnvironmentObject private var contentViewModel: ContentViewModel
    
    @State private var showingPrivateKeyImporter = false
    @State private var showingPrivateKeyError = false
    
    var body: some View {
        Form {
            Section {
                TextField("Issuer ID", text: $issuerID)
                TextField("Private Key ID", text: $privateKeyID)
                VStack(alignment: .leading) {
                    HStack {
                        Button("Select Private Key") {
                            self.showingPrivateKeyImporter = true
                        }
                        if privateKey.isEmpty {
                            Text("No key selected")
                        } else {
                            Text("Key valid")
                        }
                    }
                    Text("**Note**: To use your .p8 private key file here, you first need to convert it to a .pem file. You can use the following command in your Terminal:\n**`openssl pkcs8 -nocrypt -in AuthKey.p8 -out AuthKey.pem`**")
                }
                .fileImporter(
                    isPresented: $showingPrivateKeyImporter,
                    allowedContentTypes: [.pem]
                ) { result in
                    if let url = result.value {
                        do {
                            self.privateKey = try Data(contentsOf: url)
                            // Re-fetch the apps
                            Task(priority: .userInitiated) {
                                await contentViewModel.fetchApps()
                            }
                        } catch {
                            print(error)
                            showingPrivateKeyError = true
                        }
                    }
                }
                .alert("Error", isPresented: $showingPrivateKeyError, actions: {
                    Button("Ok") {}
                }) {
                    Text("There was an error processing the private key. Please make sure that it is in PKCS#8 format.")
                }
            }
            Section {
                List(devices, id: \.name) { device in
                    HStack {
                        Text(device.name)
                        Spacer()
                        Text(device.screenshotDisplayType.displayName)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 800, minHeight: 500)
    }
    
    // TODO: Add an editable list for configuring devices
}

extension UTType {
    static let pem = UTType(filenameExtension: "pem")!
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
