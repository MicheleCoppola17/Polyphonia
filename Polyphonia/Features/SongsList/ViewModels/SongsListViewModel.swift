//
//  SongsListViewModel.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import Observation
import SwiftData

@MainActor
@Observable
class SongsListViewModel {
    var songs: [Song] = []
    var isAddingSong = false
    var newSongTitle = ""
    
    private var service: SongService?
    
    init() {}
    
    func onAppear(modelContext: ModelContext) {
        self.service = SongService(modelContext: modelContext)
        fetchSongs()
    }
    
    func fetchSongs() {
        guard let service else { return }
        do {
            songs = try service.fetchAllSongs()
        } catch {
            print("Failed to fetch songs: \(error)")
        }
    }
    
    func addSong() {
        guard !newSongTitle.isEmpty, let service else { return }
        service.createSong(title: newSongTitle)
        newSongTitle = ""
        isAddingSong = false
        fetchSongs()
    }
    
    func deleteSong(at offsets: IndexSet) {
        guard let service else { return }
        for index in offsets {
            let song = songs[index]
            service.deleteSong(song)
        }
        fetchSongs()
    }
}
