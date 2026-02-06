//
//  AudioImportService.swift
//  Polyphonia
//
//  Created by Gemini.
//

import Foundation
import AVFoundation

enum AudioImportError: Error {
    case securityAccessDenied
    case copyFailed
    case invalidAudioFormat
}

actor AudioImportService {
    
    /// Imports an audio file from an external URL (e.g., from file importer).
    /// Handles security scoped URLs, copies the file to the app's documents directory,
    /// and retrieves basic metadata.
    /// - Parameter url: The source URL of the audio file.
    /// - Returns: A tuple containing the local persistent URL and the duration of the audio.
    func importAudio(from url: URL) async throws -> (localURL: URL, duration: TimeInterval) {
        
        // 1. Handle Security Scoping
        // Start accessing the security-scoped resource.
        // This is required for URLs returned by UIDocumentPickerViewController / fileImporter.
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // 2. Prepare Destination
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AudioImportError.copyFailed
        }
        
        let originalExtension = url.pathExtension
        // Normalize naming: Use UUID to avoid collisions and strange characters
        // Default to "m4a" if extension is missing, though most audio files will have one.
        let extensionToUse = originalExtension.isEmpty ? "m4a" : originalExtension
        let newFileName = UUID().uuidString + "." + extensionToUse
        let destinationURL = documentsURL.appendingPathComponent(newFileName)
        
        // 3. Copy File
        // We perform the copy while we have security access.
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)
        } catch {
            print("Copy error: \(error)")
            throw AudioImportError.copyFailed
        }
        
        // 4. Retrieve Metadata (Duration) from the *local* copy
        // We use the local copy to avoid security scope issues with AVFoundation
        do {
            // Attempt to load duration using AVURLAsset (modern async API)
            let asset = AVURLAsset(url: destinationURL)
            let durationCMTime = try await asset.load(.duration)
            let duration = durationCMTime.seconds
            
            // Validate duration
            if duration.isNaN || duration.isZero {
                 // Fallback: Try AVAudioFile which sometimes handles raw headers better
                let audioFile = try AVAudioFile(forReading: destinationURL)
                let sampleRate = audioFile.fileFormat.sampleRate
                let frameCount = audioFile.length
                
                guard sampleRate > 0 else { throw AudioImportError.invalidAudioFormat }
                
                let fileDuration = Double(frameCount) / sampleRate
                return (destinationURL, fileDuration)
            }
            
            return (destinationURL, duration)
            
        } catch {
            print("Metadata error: \(error)")
            // If we can't read audio metadata, it might not be a valid audio file.
            // Cleanup the copied file so we don't leave garbage.
            try? fileManager.removeItem(at: destinationURL)
            throw AudioImportError.invalidAudioFormat
        }
    }
}