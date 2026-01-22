//
//  RecordingViewModel.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI
import Observation

@MainActor
@Observable
class RecordingViewModel {
    var isRecording: Bool = false
    
    init() {}
    
    func toggleRecording() {
        isRecording.toggle()
    }
}
