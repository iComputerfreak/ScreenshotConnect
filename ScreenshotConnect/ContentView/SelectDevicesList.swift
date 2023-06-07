//
//  SelectDevicesList.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectDevicesList: View {
    @Binding var classificationResults: [Result<AppScreenshot, ScreenshotClassifier.Error>]
    @Binding var selectedDevices: Set<Device>
    
    private var screenshotsByDevice: [Device: [AppScreenshot]] {
        return Dictionary(grouping: classificationResults.compactMap(\.value), by: \.device)
    }
    
    var body: some View {
        List {
            ForEach(Array(screenshotsByDevice.keys.sorted(on: \.name, by: <)), id: \.name) { device in
                let screenshotCount = screenshotsByDevice[device]?.count ?? 0
                Toggle(isOn: selectedDevicesProxy(for: device)) {
                    HStack {
                        Text(device.name)
                        Spacer()
                        Text("\(screenshotCount) screenshots")
                    }
                }
            }
        }
    }
    
    private func selectedDevicesProxy(for device: Device) -> Binding<Bool> {
        Binding {
            selectedDevices.contains(device)
        } set: { newValue in
            if newValue == true, !selectedDevices.contains(device) {
                selectedDevices.insert(device)
            } else {
                selectedDevices.remove(device)
            }
        }
    }
}

//#Preview {
//    SelectDevicesList(classificationResults: .constant([]), selectedDevices: .constant([]))
//}
