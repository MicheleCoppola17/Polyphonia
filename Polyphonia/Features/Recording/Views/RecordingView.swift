//
//  RecordingView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import SwiftData

struct RecordingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RecordingViewModel()
    
    let song: Song

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                if viewModel.recordedURL == nil {
                    // Recording State
                    recordingControls
                } else {
                    // Review State
                    reviewControls
                }
            }
            .padding()
            .navigationTitle("New Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.discard()
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isRecording)
        }
    }
    
    private var recordingControls: some View {
        VStack(spacing: 20) {
            Text(viewModel.isRecording ? "Recording..." : "Ready")
                .font(.headline)
                .foregroundStyle(viewModel.isRecording ? .red : .secondary)
            
            Button {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundStyle(viewModel.isRecording ? .red : .primary)
                        .frame(width: 80, height: 80)
                    
                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red)
                            .frame(width: 40, height: 40)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .padding()
        }
    }
    
    private var reviewControls: some View {
        VStack(spacing: 20) {
            TextField("Idea Title", text: $viewModel.ideaTitle)
                .textFieldStyle(.roundedBorder)
                .font(.headline)
            
            Text("Recording captured")
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                Button("Discard", role: .destructive) {
                    withAnimation {
                        viewModel.discard()
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    viewModel.save(to: song, modelContext: modelContext)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Song.self, configurations: config)
    let song = Song(title: "Preview Song")
    container.mainContext.insert(song)
    
    return RecordingView(song: song)
        .modelContainer(container)
}
