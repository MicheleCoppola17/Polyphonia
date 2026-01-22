//
//  SongService.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import Foundation

@MainActor
class SongService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchSongs(searchString: String = "") throws -> [Song] {
        let predicate = #Predicate<Song> { song in
            searchString.isEmpty ? true : song.title.localizedStandardContains(searchString)
        }
        let descriptor = FetchDescriptor<Song>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func createSong(title: String) {
        let song = Song(title: title)
        modelContext.insert(song)
        // Auto-save is enabled by default in SwiftUI context, but explicit save is good for services
        try? modelContext.save()
    }
    
    func deleteSong(_ song: Song) {
        modelContext.delete(song)
        try? modelContext.save()
    }
    
    func addAudioIdea(to song: Song, title: String, url: URL) {
        let idea = AudioIdea(title: title, url: url)
        idea.song = song // Relationship is managed
        // Inserting idea into context is implicitly done when adding to relationship if song is in context
        // But safer to insert explicitly or rely on SwiftData's relationship management
        modelContext.insert(idea)
        try? modelContext.save()
    }
}
