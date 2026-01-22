//
//  AudioRecorderService.swift
//  Polyphonia
//
//  Created by Gemini.
//

import Foundation
import AVFoundation

enum AudioRecorderError: Error {
    case permissionDenied
    case recordingFailed
    case noActiveRecording
    case audioSessionSetupFailed
}

@MainActor
class AudioRecorderService: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    override init() {
        super.init()
    }
    
    /// Requests microphone permission if not determined, and throws if denied.
    private func ensurePermission() async throws {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                return
            case .denied:
                throw AudioRecorderError.permissionDenied
            case .undetermined:
                let granted = await AVAudioApplication.requestRecordPermission()
                if !granted {
                    throw AudioRecorderError.permissionDenied
                }
            @unknown default:
                throw AudioRecorderError.permissionDenied
            }
        } else {
            let session = AVAudioSession.sharedInstance()
            switch session.recordPermission {
            case .granted:
                return
            case .denied:
                throw AudioRecorderError.permissionDenied
            case .undetermined:
                let granted = await withCheckedContinuation { continuation in
                    session.requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
                if !granted {
                    throw AudioRecorderError.permissionDenied
                }
            @unknown default:
                throw AudioRecorderError.permissionDenied
            }
        }
    }
    
    /// Configures the audio session for recording.
    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Audio Session setup error: \(error)")
            throw AudioRecorderError.audioSessionSetupFailed
        }
    }
    
    /// Starts recording to a new file in the Documents directory.
    /// - Parameter filename: The name of the file (without extension). If nil, a UUID is used.
    func startRecording(filename: String? = nil) async throws {
        try await ensurePermission()
        try setupAudioSession()
        
        let name = filename ?? UUID().uuidString
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(name).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.delegate = self
            if recorder.record() {
                self.audioRecorder = recorder
                self.recordingURL = url
            } else {
                throw AudioRecorderError.recordingFailed
            }
        } catch {
            throw AudioRecorderError.recordingFailed
        }
    }
    
    /// Stops the recording and returns the file URL and duration.
    func stopRecording() async throws -> (URL, TimeInterval) {
        guard let recorder = audioRecorder, let url = recordingURL else {
            throw AudioRecorderError.noActiveRecording
        }
        
        let duration = recorder.currentTime
        recorder.stop()
        
        // Deactivate session (optional, but good practice to allow other apps to resume audio)
        // However, in a music app, we might want to keep it active or switch to playback.
        // For now, we leave it or deactivate asynchronously.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        self.audioRecorder = nil
        self.recordingURL = nil
        
        return (url, duration)
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // Handle unexpected stops if necessary, though explicit stop() handles the success case.
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            print("Audio recorder encode error: \(error)")
        }
    }
}
