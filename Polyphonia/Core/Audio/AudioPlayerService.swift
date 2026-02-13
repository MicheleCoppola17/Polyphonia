//
//  AudioPlayerService.swift
//  Polyphonia
//
//  Created by Gemini.
//

import Foundation
import AVFoundation
import Combine

@MainActor
class AudioPlayerService: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying: Bool = false
//    @Published var currentlyPlayingURL: URL?
    @Published var currentlyPlayingID: UUID?
    @Published var errorMessage: String?
    
    override init() {
        super.init()
    }
    
    func play(idea: AudioIdea) {
        errorMessage = nil
        stop()
        
        // 1. Determine local path
        let fileName = idea.id.uuidString + ".m4a"
        let currentURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // 2. Restore file from iCloud data if missing
        if !FileManager.default.fileExists(atPath: currentURL.path) {
            if let data = idea.audioData {
                try? data.write(to: currentURL)
            } else {
                errorMessage = "Audio file not found."
                return
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: currentURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentlyPlayingID = idea.id
            isPlaying = true
        } catch {
            errorMessage = "Playback failed: \(error.localizedDescription)"
            stop()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentlyPlayingID = nil
        isPlaying = false
    }
    
    func togglePlayPause(idea: AudioIdea) {
        if currentlyPlayingID == idea.id && isPlaying {
            pause()
        } else {
            play(idea: idea)
        }
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.stop()
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error {
            print("Audio player decode error: \(error)")
            Task { @MainActor in
                self.errorMessage = "Decode error: \(error.localizedDescription)"
                self.stop()
            }
        } else {
            Task { @MainActor in
                self.stop()
            }
        }
    }
}
