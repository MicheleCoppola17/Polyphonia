//
//  SongDetailView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

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
            timelineContent
        }
        .navigationTitle(viewModel.song.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                menuButton
            }
        }
        .sheet(isPresented: $viewModel.isPresentingRecording) {
            RecordingView(song: viewModel.song)
        }
        .fileImporter(
            isPresented: $viewModel.isImportingFile,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            let mappedResult = result.map { $0.first! } // Force unwrap safe because success implies at least one URL if single selection
            viewModel.importAudio(result: mappedResult, modelContext: modelContext)
        }
        .overlay(alignment: .bottom) {
            errorOverlay
        }
        .overlay {
            emptyStateOverlay
        }
    }
    
    private var timelineContent: some View {
        ZStack(alignment: .leading) {
            // Vertical Timeline Line
            Rectangle()
                .fill(viewModel.sortedAudioIdeas.isEmpty ? Color.clear : Color.gray.opacity(0.3))
                .frame(width: 2)
                .padding(.leading, 21) // Center of the 12pt dot + padding
                .padding(.top, 15) // Offset for header
            
            VStack(alignment: .leading, spacing: 24) {
                LazyVStack(spacing: 24) {
                    ForEach(viewModel.sortedAudioIdeas) { idea in
                        TimelineRow(idea: idea, isPlaying: viewModel.isPlaying(idea: idea)) {
                            viewModel.togglePlayback(for: idea)
                        }
                        .contextMenu {
                            contextMenuContent(for: idea)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    @ViewBuilder
    private func contextMenuContent(for idea: AudioIdea) -> some View {
        Section("Status") {
            ForEach(IdeaStatus.allCases, id: \.self) { status in
                Button {
                    viewModel.updateStatus(for: idea, to: status, modelContext: modelContext)
                } label: {
                    if idea.status == status {
                        Label(status.title, systemImage: "checkmark")
                    } else {
                        Text(status.title)
                    }
                }
            }
        }
        
        Section {
            Button(role: .destructive) {
                viewModel.deleteAudioIdea(idea, modelContext: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var menuButton: some View {
        Menu {
            Button {
                viewModel.isPresentingRecording = true
            } label: {
                Label("Record New Idea", systemImage: "mic.badge.plus")
            }
            
            Button {
                viewModel.isImportingFile = true
            } label: {
                Label("Import Audio File", systemImage: "arrow.down.doc")
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    
    @ViewBuilder
    private var errorOverlay: some View {
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
    
    @ViewBuilder
    private var emptyStateOverlay: some View {
        if viewModel.sortedAudioIdeas.isEmpty {
            ContentUnavailableView(
                "No Ideas Yet",
                systemImage: "music.mic",
                description: Text("Tap + to record your first idea.")
            )
            .padding(.top, 40)
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text(idea.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    StatusBadge(status: idea.status)
                }
                
                HStack(spacing: 16) {
                    Button(action: onTogglePlay) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(Color.accentColor)
                    }
                    
                    // Waveform placeholder (visual only)
                    HStack(spacing: 4) {
                        ForEach(0..<18) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.accentColor.opacity(0.3))
                                .frame(width: 4, height: .random(in: 10...24))
                        }
                    }
                    
                    Spacer()
                    
                    // Duration Placeholder
                    Text(idea.duration.mmSS)
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
            .padding(.top, 15)
        }
    }
}

struct StatusBadge: View {
    let status: IdeaStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.title)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// Helper for status UI
private extension IdeaStatus {
    var title: String {
        switch self {
        case .draft: return "Draft"
        case .favorite: return "Favorite"
        case .final: return "Final"
        }
    }
    
    var icon: String {
        switch self {
        case .draft: return "pencil"
        case .favorite: return "star.fill"
        case .final: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return .secondary
        case .favorite: return .orange
        case .final: return .green
        }
    }
}

extension TimeInterval {
    var mmSS: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let container = PersistenceController.preview.container
    let context = container.mainContext
    let descriptor = FetchDescriptor<Song>()
    let song = (try? context.fetch(descriptor).first) ?? Song(title: "Fallback Song")
    
    // Clean up old ideas in preview context to avoid duplicates if preview runs multiple times
    // In a real app we wouldn't delete, but for preview stability:
    // try? context.delete(model: AudioIdea.self)
    
    if song.audioIdeas.isEmpty {
        let idea1 = AudioIdea(title: "Draft Riff", url: URL(fileURLWithPath: "/dev/null"), status: .draft)
        idea1.song = song
        
        let idea2 = AudioIdea(title: "Good Take", url: URL(fileURLWithPath: "/dev/null"), status: .favorite)
        idea2.song = song
        
        let idea3 = AudioIdea(title: "Final Mix", url: URL(fileURLWithPath: "/dev/null"), status: .final)
        idea3.song = song
        
        context.insert(idea1)
        context.insert(idea2)
        context.insert(idea3)
    }
    
    return NavigationStack {
        SongDetailView(song: song)
    }
    .modelContainer(container)
}
