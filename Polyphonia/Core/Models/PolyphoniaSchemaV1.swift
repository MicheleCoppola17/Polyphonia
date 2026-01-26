//
//  PolyphoniaSchemaV1.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import Foundation

enum PolyphoniaSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Song.self, AudioIdea.self]
    }
    
    @Model
    final class Song {
        var id: UUID
        var title: String
        var createdAt: Date
        
        @Relationship(deleteRule: .cascade, inverse: \AudioIdea.song)
        var audioIdeas: [AudioIdea] = []
        
        init(id: UUID = UUID(), title: String, createdAt: Date = Date()) {
            self.id = id
            self.title = title
            self.createdAt = createdAt
        }
    }
    
    @Model
    final class AudioIdea {
        var id: UUID
        var title: String
        var createdAt: Date
        var url: URL
        var duration: TimeInterval
        var song: Song?
        
        init(id: UUID = UUID(), title: String, createdAt: Date = Date(), url: URL, duration: TimeInterval = 0) {
            self.id = id
            self.title = title
            self.createdAt = createdAt
            self.url = url
            self.duration = duration
        }
    }
}
