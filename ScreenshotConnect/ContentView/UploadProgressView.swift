//
//  UploadProgressView.swift
//  ScreenshotConnect
//
//  Created by Jonas Frey on 10.09.23.
//

import SwiftUI

struct UploadProgressView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var progressPercentage: Double {
        switch viewModel.uploadState {
        case .uploadingScreenshots(let current, let total):
            return Double(current) / Double(total)
        case .uploadSuccessful:
            return 1
        case .idle, .preparing, .deletingExisting, .error:
            return 0
        }
    }
    
    var body: some View {
        if case UploadState.idle = viewModel.uploadState {
            // We don't show any progress in idle state
        } else {
            ProgressView(value: progressPercentage) {
                Text(viewModel.uploadState.localized)
            } currentValueLabel: {
                if case let .uploadingScreenshots(current: current, total: total) = viewModel.uploadState {
                    Text("\(current) / \(total)")
                } else {
                    EmptyView()
                }
            }
            if case let .error(error) = viewModel.uploadState {
                Text("\(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    UploadProgressView()
}
