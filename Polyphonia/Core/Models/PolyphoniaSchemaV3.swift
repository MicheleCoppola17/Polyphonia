//
//  PolyphoniaSchemaV3.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import Foundation

enum PolyphoniaSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(3, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Song.self, AudioIdea.self]
    }
    
    enum IdeaStatus: String, Codable, CaseIterable, Sendable {
        case draft
        case favorite
        case final
    }
    
    @Model
    final class Song {
        var id: UUID = UUID()
        var title: String = ""
        var createdAt: Date = Date()
        
        @Relationship(deleteRule: .cascade, inverse: \AudioIdea.song)
        var audioIdeas: [AudioIdea]? = []
        
        init(id: UUID = UUID(), title: String = "", createdAt: Date = Date()) {
            self.id = id
            self.title = title
            self.createdAt = createdAt
        }
    }
    
    @Model
    final class AudioIdea {
        var id: UUID = UUID()
        var title: String = ""
        var createdAt: Date = Date()
        var url: URL? = nil
        var duration: TimeInterval = 0
        var status: IdeaStatus = IdeaStatus.draft
        var song: Song?
        
        // Add this attribute to sync the actual audio data
        @Attribute(.externalStorage)
        var audioData: Data? = nil
        
        init(id: UUID = UUID(), title: String = "", createdAt: Date = Date(), url: URL? = nil, duration: TimeInterval = 0, status: IdeaStatus = .draft, audioData: Data? = nil) {
            self.id = id
            self.title = title
            self.createdAt = createdAt
            self.url = url
            self.duration = duration
            self.status = status
            self.audioData = audioData
        }
    }
}
