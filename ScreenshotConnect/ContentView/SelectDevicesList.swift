//
//  SelectDevicesList.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 07.06.23.
//

import SwiftUI

struct SelectDevicesList: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    private var screenshotsByDevice: [Device: [AppScreenshot]] {
        return Dictionary(grouping: viewModel.classificationResults.compactMap(\.value), by: \.device)
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
            viewModel.selectedDevices.contains(device)
        } set: { newValue in
            if newValue == true, !viewModel.selectedDevices.contains(device) {
                viewModel.selectedDevices.insert(device)
            } else {
                viewModel.selectedDevices.remove(device)
            }
        }
    }
}

//#Preview {
//    SelectDevicesList(classificationResults: .constant([]), selectedDevices: .constant([]))
//}
