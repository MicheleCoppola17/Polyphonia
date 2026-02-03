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
    @Published var errorMessage: String?
    
    override init() {
        super.init()
    }
    
    func play(url: URL) {
        errorMessage = nil
//        // If we are already playing this URL, just resume
//        if let currentlyPlayingURL = currentlyPlayingURL, currentlyPlayingURL == url, let player = audioPlayer {
//            if !player.isPlaying {
//                player.play()
//                isPlaying = true
//            }
//            return
//        }
        
        let fileName = url.lastPathComponent
        let currentURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // Otherwise, stop current and start new
        stop()
        
        do {
            // Ensure session is active
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: currentURL)
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentlyPlayingURL = url
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
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
