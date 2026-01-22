//
//  SongDetailView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import SwiftUI

struct SongDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SongDetailViewModel
    // Observe the player service explicitly to trigger view updates
    @ObservedObject private var playerService: AudioPlayerService
    
    init(song: Song) {
        let vm = SongDetailViewModel(song: song)
        _viewModel = State(wrappedValue: vm)
        _playerService = ObservedObject(wrappedValue: vm.playerService)
    }
    
    var body: some View {
        List {
            if viewModel.sortedAudioIdeas.isEmpty {
                ContentUnavailableView(
                    "No Ideas Yet",
                    systemImage: "music.mic",
                    description: Text("Tap + to record your first idea.")
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.sortedAudioIdeas) { idea in
                    HStack {
                        Button {
                            viewModel.togglePlayback(for: idea)
                        } label: {
                            Image(systemName: viewModel.isPlaying(idea: idea) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading) {
                            Text(idea.title)
                                .font(.headline)
                            Text(idea.createdAt, format: .dateTime.month().day().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let idea = viewModel.sortedAudioIdeas[index]
                        viewModel.deleteAudioIdea(idea, modelContext: modelContext)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.song.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isPresentingRecording = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingRecording) {
            RecordingView(song: viewModel.song)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Song.self, configurations: config)
    let song = Song(title: "Preview Song")
    container.mainContext.insert(song)
    
    // Add dummy audio idea
    let idea = AudioIdea(title: "Riff 1", url: URL(fileURLWithPath: "/dev/null"))
    idea.song = song
    container.mainContext.insert(idea)
    
    return NavigationStack {
        SongDetailView(song: song)
    }
    .modelContainer(container)
}
