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
    @State private var isPresentingRecording = false
    
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
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteSong(at: indexSet)
                }
            }
            .navigationTitle("Songs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            isPresentingRecording = true
                        } label: {
                            Image(systemName: "mic.badge.plus")
                        }
                        
                        Button {
                            viewModel.isAddingSong = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationDestination(for: Song.self) { song in
                SongDetailView(song: song)
            }
            .sheet(isPresented: $isPresentingRecording) {
                RecordingView()
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
        }
    }
}

#Preview {
    SongsListView()
        .modelContainer(PersistenceController.preview.container)
}