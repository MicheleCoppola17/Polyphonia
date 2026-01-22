//
//  RecordingViewModel.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import Observation
import SwiftData

@MainActor
@Observable
class RecordingViewModel {
    var isRecording: Bool = false
    var ideaTitle: String = ""
    var recordedURL: URL?
    var errorMessage: String?
    
    private let audioService = AudioRecorderService()
    
    init() {}
    
    func startRecording() {
        Task {
            do {
                errorMessage = nil
                try await audioService.startRecording()
                isRecording = true
            } catch {
                errorMessage = "Failed to start recording: \(error.localizedDescription)"
            }
        }
    }
    
    func stopRecording() {
        Task {
            do {
                let (url, _) = try await audioService.stopRecording()
                isRecording = false
                recordedURL = url
                if ideaTitle.isEmpty {
                    ideaTitle = "New Idea \(Date().formatted(date: .omitted, time: .shortened))"
                }
            } catch {
                errorMessage = "Failed to stop recording: \(error.localizedDescription)"
                isRecording = false
            }
        }
    }
    
    func save(to song: Song, modelContext: ModelContext) {
        guard let url = recordedURL, !ideaTitle.isEmpty else { return }
        let service = SongService(modelContext: modelContext)
        service.addAudioIdea(to: song, title: ideaTitle, url: url)
    }
    
    func discard() {
        // In a real app, we might want to delete the file at recordedURL here
        recordedURL = nil
        ideaTitle = ""
        errorMessage = nil
        isRecording = false
    }
}
