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
        song.audioIdeas.sorted { $0.createdAt > $1.createdAt }
    }
    
    func deleteAudioIdea(_ idea: AudioIdea, modelContext: ModelContext) {
        if playerService.currentlyPlayingURL == idea.url {
            playerService.stop()
        }
        
        // Remove file from disk
        try? FileManager.default.removeItem(at: idea.url)
        
        // Remove from SwiftData
        modelContext.delete(idea)
        // Explicit save is good practice, though often handled by auto-save
        try? modelContext.save()
    }
    
    func togglePlayback(for idea: AudioIdea) {
        playerService.togglePlayPause(url: idea.url)
    }
    
    func updateStatus(for idea: AudioIdea, to status: IdeaStatus, modelContext: ModelContext) {
        idea.status = status
        try? modelContext.save()
    }
    
    func isPlaying(idea: AudioIdea) -> Bool {
        return playerService.isPlaying && playerService.currentlyPlayingURL == idea.url
    }
}
