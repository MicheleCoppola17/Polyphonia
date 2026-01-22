//
//  RecordingView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI

struct RecordingView: View {
    @State private var viewModel = RecordingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Recording Screen")
                .font(.largeTitle)
            
            Text(viewModel.isRecording ? "Recording..." : "Ready to Record")
                .foregroundStyle(viewModel.isRecording ? .red : .primary)
                .padding()
            
            Button {
                viewModel.toggleRecording()
            } label: {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    RecordingView()
}
