//
//  PersistenceController.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import SwiftUI

@MainActor
class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema(PolyphoniaSchemaV3.models)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            container = try ModelContainer(
                for: schema,
                migrationPlan: PolyphoniaMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.mainContext
        // Add sample data
        let song = Song(title: "Sample Song")
        viewContext.insert(song)
        return result
    }()
}
