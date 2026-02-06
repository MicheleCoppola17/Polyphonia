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
    var recordedDuration: TimeInterval = 0
    var isRecording: Bool = false
    var ideaTitle: String = ""
    var recordedURL: URL?
    var errorMessage: String?
    var currentAmplitude: Float = 0
    
    private let audioService = AudioRecorderService()
    private var meteringTask: Task<Void, Never>?
    
    init() {}
    
    func startRecording() {
        Task {
            do {
                errorMessage = nil
                try await audioService.startRecording()
                isRecording = true
                
                meteringTask?.cancel()
                meteringTask = Task {
                    for await level in audioService.amplitudeStream() {
                        self.currentAmplitude = level
                        print(currentAmplitude)
                    }
                }
            } catch {
                errorMessage = "Failed to start recording: \(error.localizedDescription)"
            }
        }
    }
    
    func stopRecording() {
        meteringTask?.cancel()
        meteringTask = nil
        currentAmplitude = 0
        
        Task {
            do {
                let (url, duration) = try await audioService.stopRecording()
                isRecording = false
                recordedURL = url
                recordedDuration = duration
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
        service.addAudioIdea(to: song, title: ideaTitle, url: url, duration: recordedDuration)
    }
    
    func discard() {
        // In a real app, we might want to delete the file at recordedURL here
        recordedURL = nil
        ideaTitle = ""
        errorMessage = nil
        isRecording = false
    }
}
