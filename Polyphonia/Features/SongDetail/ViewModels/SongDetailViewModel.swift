//
//  SongDetailViewModel.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import Observation
import SwiftData

@MainActor
@Observable
class SongDetailViewModel {
    var song: Song
    var isPresentingRecording = false
    var isImportingFile = false
    
    private let importService = AudioImportService()
    
    // We observe the service manually or just access its properties if it was also @Observable (Swift 5.9+)
    // Since AudioPlayerService is a class, we need to ensure UI updates when its published properties change.
    // However, @Observable classes don't automatically observe ObservableObjects.
    // A simpler approach for this architecture: let the view observe the service, or wrap it.
    // For now, we will expose the service directly.
    let playerService = AudioPlayerService()
    
    init(song: Song) {
        self.song = song
    }
    
    var sortedAudioIdeas: [AudioIdea] {
        (song.audioIdeas ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    func importAudio(result: Result<URL, Error>, modelContext: ModelContext) {
        Task {
            do {
                let url = try result.get()
                let (localURL, duration) = try await importService.importAudio(from: url)
                
                let title = url.deletingPathExtension().lastPathComponent
                let idea = AudioIdea(title: title, url: localURL, duration: duration)
                idea.song = song
                
                modelContext.insert(idea)
                try? modelContext.save()
            } catch {
                print("Import failed: \(error)")
            }
        }
    }
    
    func deleteAudioIdea(_ idea: AudioIdea, modelContext: ModelContext) {
        if playerService.currentlyPlayingURL == idea.url {
            playerService.stop()
        }
        
        // Remove file from disk
        if let url = idea.url {
            try? FileManager.default.removeItem(at: url)
        }
        
        // Remove from SwiftData
        modelContext.delete(idea)
        // Explicit save is good practice, though often handled by auto-save
        try? modelContext.save()
    }
    
    func togglePlayback(for idea: AudioIdea) {
        if let url = idea.url {
            playerService.togglePlayPause(url: url)
        }
    }
    
    func updateStatus(for idea: AudioIdea, to status: IdeaStatus, modelContext: ModelContext) {
        idea.status = status
        try? modelContext.save()
    }
    
    func isPlaying(idea: AudioIdea) -> Bool {
        return playerService.isPlaying && playerService.currentlyPlayingURL == idea.url
    }
}
