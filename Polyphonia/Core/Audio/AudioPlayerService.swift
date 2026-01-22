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
    @Published var currentlyPlayingURL: URL?
    
    override init() {
        super.init()
    }
    
    func play(url: URL) {
        // If we are already playing this URL, just resume
        if let currentlyPlayingURL = currentlyPlayingURL, currentlyPlayingURL == url, let player = audioPlayer {
            if !player.isPlaying {
                player.play()
                isPlaying = true
            }
            return
        }
        
        // Otherwise, stop current and start new
        stop()
        
        do {
            // Ensure session is active
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentlyPlayingURL = url
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
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
        currentlyPlayingURL = nil
        isPlaying = false
    }
    
    func togglePlayPause(url: URL) {
        if currentlyPlayingURL == url && isPlaying {
            pause()
        } else {
            play(url: url)
        }
    }
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
        }
        Task { @MainActor in
            self.stop()
        }
    }
}
