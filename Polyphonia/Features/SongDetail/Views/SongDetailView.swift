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
    @ObservedObject private var playerService: AudioPlayerService
    
    init(song: Song) {
        let vm = SongDetailViewModel(song: song)
        _viewModel = State(wrappedValue: vm)
        _playerService = ObservedObject(wrappedValue: vm.playerService)
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .leading) {
                // Vertical Timeline Line
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
                    .padding(.leading, 21) // Center of the 12pt dot + padding
                    .padding(.top, 80) // Offset for header
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.song.title)
                            .font(.system(size: 34, weight: .bold))
                        Text("\(viewModel.sortedAudioIdeas.count) takes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 44) // Align with content card
                    .padding(.top, 20)
                    
                    if viewModel.sortedAudioIdeas.isEmpty {
                        ContentUnavailableView(
                            "No Ideas Yet",
                            systemImage: "music.mic",
                            description: Text("Tap + to record your first idea.")
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 24) {
                            ForEach(viewModel.sortedAudioIdeas) { idea in
                                TimelineRow(idea: idea, isPlaying: viewModel.isPlaying(idea: idea)) {
                                    viewModel.togglePlayback(for: idea)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteAudioIdea(idea, modelContext: modelContext)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
        .overlay(alignment: .bottom) {
            if let error = playerService.errorMessage {
                Text(error)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.red.cornerRadius(8))
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if playerService.errorMessage == error {
                                playerService.errorMessage = nil
                            }
                        }
                    }
            }
        }
    }
}

struct TimelineRow: View {
    let idea: AudioIdea
    let isPlaying: Bool
    let onTogglePlay: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline Dot
            Circle()
                .fill(Color.accentColor)
                .frame(width: 12, height: 12)
                .background(Color(uiColor: .systemBackground).frame(width: 20, height: 20)) // Gap effect
                .padding(.leading, 16)
                .offset(y: 24) // Align roughly with the play button center
            
            // Card
            VStack(alignment: .leading, spacing: 16) {
                Text(idea.title)
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Button(action: onTogglePlay) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    // Waveform placeholder (visual only)
                    HStack(spacing: 4) {
                        ForEach(0..<22) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accentColor.opacity(0.3))
                                .frame(width: 4, height: .random(in: 10...24))
                        }
                    }
                    
                    Spacer()
                    
                    // Duration Placeholder (since we don't store it yet)
                    Text("0:00")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                
                Text(idea.createdAt, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(16)
            .padding(.trailing, 16)
        }
    }
}

#Preview {
    let container = PersistenceController.preview.container
    let context = container.mainContext
    let descriptor = FetchDescriptor<Song>()
    let song = (try? context.fetch(descriptor).first) ?? Song(title: "Fallback Song")
    
    // Add dummy audio idea for preview if none exists
    if song.audioIdeas.isEmpty {
        let idea = AudioIdea(title: "Riff 1", url: URL(fileURLWithPath: "/dev/null"))
        idea.song = song
        context.insert(idea)
    }
    
    return NavigationStack {
        SongDetailView(song: song)
    }
    .modelContainer(container)
}
