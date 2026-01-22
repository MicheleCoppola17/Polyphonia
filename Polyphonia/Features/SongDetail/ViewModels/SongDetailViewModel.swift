//
//  SongDetailViewModel.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import Observation

@MainActor
@Observable
class SongDetailViewModel {
    var song: Song
    
    init(song: Song) {
        self.song = song
    }
}
