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
            VStack {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
                
                // 1. Top/Center Area: Visualization
                Spacer()
                
                if viewModel.recordedURL == nil {
                    // Show the Wave Visualizer while recording or ready
                    // We pass the amplitude from the viewModel
                    if viewModel.isRecording {
                        WaveParticlesView(amplitude: viewModel.currentAmplitude, color: .red)
                            .frame(height: 200)
                    } else {
                        // I have to think what to put
                    }
                } else {
                    // Review State Central UI
                    VStack(spacing: 20) {
                        Image(systemName: "waveform")
                            .font(.system(size: 60))
                            .foregroundStyle(.primary)
                        Text("Recording Captured")
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                // 2. Bottom Area: Controls
                VStack {
                    if viewModel.recordedURL == nil {
                        recordingControls
                    } else {
                        reviewControls
                    }
                }
                .padding(.bottom, 30) // Adds some breathing room from the bottom edge
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground)) // Optional: keeps controls legible
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
            Text(viewModel.isRecording ? "Tap to Stop" : "Tap to Record")
                .font(.subheadline)
                .fontWeight(.medium)
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
                        .foregroundStyle(viewModel.isRecording ? .red.opacity(0.3) : .primary.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red)
                            .frame(width: 35, height: 35)
                            // Subtle pulse effect
                            .shadow(color: .red, radius: viewModel.currentAmplitude > 0.5 ? 10 : 0)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: 65, height: 65)
                    }
                }
            }
        }
    }
    
    private var reviewControls: some View {
        VStack(spacing: 24) {
            TextField("Idea Title", text: $viewModel.ideaTitle)
                .textFieldStyle(.roundedBorder)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button("Discard", role: .destructive) {
                    withAnimation {
                        viewModel.discard()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("Save Idea") {
                    viewModel.save(to: song, modelContext: modelContext)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let container = PersistenceController.preview.container
    let context = container.mainContext
    // Fetch the sample song created in PersistenceController.preview
    let descriptor = FetchDescriptor<Song>()
    let song = (try? context.fetch(descriptor).first) ?? Song(title: "Fallback Song")
    
    return RecordingView(song: song)
        .modelContainer(container)
}
