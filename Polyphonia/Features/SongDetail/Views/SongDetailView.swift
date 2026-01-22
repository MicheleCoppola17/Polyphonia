//
//  SongDetailView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import SwiftUI

struct SongDetailView: View {
    @State private var viewModel: SongDetailViewModel
    
    init(song: Song) {
        _viewModel = State(wrappedValue: SongDetailViewModel(song: song))
    }
    
    var body: some View {
        VStack {
            Text(viewModel.song.title)
                .font(.title)
            
            Text("Details placeholder")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Song Detail")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Song.self, configurations: config)
    let song = Song(title: "Preview Song")
    container.mainContext.insert(song)
    
    return NavigationStack {
        SongDetailView(song: song)
    }
    .modelContainer(container)
}
