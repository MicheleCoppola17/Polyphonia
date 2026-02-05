//
//  SongsListView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import SwiftData

struct SongsListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SongsListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.songs) { song in
                    NavigationLink(value: song) {
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.createdAt, format: .dateTime.year().month().day())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical)
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteSong(at: indexSet)
                }
            }
            .navigationTitle("Songs")
            .searchable(text: $viewModel.searchText, prompt: "Search songs")
            .onChange(of: viewModel.searchText) {
                viewModel.fetchSongs()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isAddingSong = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Song.self) { song in
                SongDetailView(song: song)
            }
            .alert("New Song", isPresented: $viewModel.isAddingSong) {
                TextField("Song Title", text: $viewModel.newSongTitle)
                Button("Cancel", role: .cancel) {
                    viewModel.isAddingSong = false
                    viewModel.newSongTitle = ""
                }
                Button("Create") {
                    viewModel.addSong()
                }
            }
            .onAppear {
                viewModel.onAppear(modelContext: modelContext)
            }
            .overlay {
                if viewModel.songs.isEmpty {
                    ContentUnavailableView(
                        "No Songs Yet",
                        systemImage: "music.note",
                        description: Text("Tap + to create your first song.")
                    )
                    .padding(40)
                }
            }
        }
    }
}

#Preview {
    SongsListView()
        .modelContainer(PersistenceController.preview.container)
}
