//
//  PolyphoniaMigrationPlan.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftData
import Foundation

enum PolyphoniaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PolyphoniaSchemaV1.self, PolyphoniaSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: PolyphoniaSchemaV1.self,
        toVersion: PolyphoniaSchemaV2.self
    )
}
