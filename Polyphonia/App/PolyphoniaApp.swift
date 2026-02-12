//
//  PolyphoniaApp.swift
//  Polyphonia
//
//  Created by Michele Coppola on 21/01/26.
//

import SwiftUI
import SwiftData

@main
struct PolyphoniaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SongsListView()
        }
        .modelContainer(persistenceController.container)
    }
}