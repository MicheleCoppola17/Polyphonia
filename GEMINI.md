# GEMINI.md

This file provides the architectural constraints and coding standards for this project. Gemini should adhere to these rules for every code generation and refactor request.

## Core Architecture & Frameworks

- **UI Framework:** Strictly **SwiftUI**. Avoid UIKit unless explicitly requested for low-level integration via `UIViewRepresentable`.
- **Pattern:** Use **MVVM (Model-View-ViewModel)**.
    - **Views:** Must be declarative and stateless. Use `@Bindable` or `@State` for local UI state only.
    - **ViewModels:** Use the `@Observable` macro (Standard in Swift 6+). Avoid the deprecated `ObservableObject` and `@Published`.
    - **Models:** Use `structs` for data. Use SwiftData `@Model` for persistence.
- **Concurrency:** Strictly follow **Swift 6 Strict Concurrency**.
    - All ViewModels must be marked with `@MainActor`.
    - Use `async/await` and `Task` groups. No completion handlers or `DispatchQueue`.
    - Ensure all data passed across boundaries is `Sendable`.

---

## Coding Best Practices

### 1. Data & Persistence
- Use **SwiftData** for local storage. 
- Prefer `#Predicate` for filtering and fetching data.
- Utilize **Schema Versions** for any model changes to ensure smooth migrations.

### 2. Networking
- Use `URLSession.shared.data(from:)` with `async/await`.
- Map API responses to `Decodable` structs.
- Implement a centralized `APIClient` or `Service` layer that returns `Result` types or throws errors.

### 3. UI & UX
- **SwiftUI Previews:** Every view file must include a `#Preview` block with mock data or a `PreviewContainer`.
- **Adaptive UI:** Support Dynamic Type, Dark Mode, and diverse screen sizes (iPhone, iPad, Vision Pro).
- **SF Symbols:** Use SF Symbols 6+ for all iconography.


---

## Instructions for AI Partner (Gemini)

1. **Check Scope:** Before proposing code, check the existing directory structure to ensure new files are placed in the correct `Modules/` or `Features/` folders.
2. **Modernity First:** If a legacy Swift pattern (like `Combine` or `completionHandlers`) is detected, suggest a refactor to modern Swift 6 equivalents.
3. **No Force Unwraps:** Never use `!`.
4. **Self-Correction:** If I provide a snippet that violates MVVM (e.g., business logic in a View), point it out and suggest the correction before writing the code.

---

## Project Structure Reference
- `/App`: Entry point and App-wide configuration.
- `/Features`: Feature-based folders containing Views, ViewModels, and Models.
- `/Core`: Networking, Persistence (SwiftData), and Extensions.
- `/Resources`: Assets and Localizable strings.

---

The file also contains the full roadmap of the project in order to give context and an overview of the big picture.

# Polyphonia

## App Idea
As a songwriter/band member, I want to record musical ideas and organize them by song so I can revisit and develop them later. I want to collaborate with my bandmates so that whenever we record a new song idea, or a new iteration of a song that we are writing, we can have its recording in the app.

## PHASE 0 — Product Foundations
**Goal**: Avoid rework later.

###Deliverables
- Product scope definition (MVP vs future)
- Architecture skeleton
- Empty but navigable app

###Tasks
- Define core user: solo songwriter
- Decide what’s OUT for v1 (collaboration, cloud, AI)
- Create project with:
    - SwiftUI
    - MVVM folders
    - Feature-based structure
- Set up:
    - App theme
    - Design system (colors, spacing, typography)

App launches, navigates, and builds cleanly

## PHASE 1 — Core MVP (Solo Songwriter)
**Goal**: Replace Voice Memos + Notes for songwriting.

### Features in this phase
1. Songs List
- Create song
- Rename song
- Delete song
- Persist locally
2. Recording Audio Ideas
- Record / stop audio
- Save audio file locally
- Title + notes
3. Song Timeline
- List of audio ideas per song
- Play / pause
- Sort by date

### Technical Focus
- AVFoundation recording
- FileManager audio storage
- Core Data for metadata
- SwiftUI state handling

### Not included yet
- Comments
- Collaboration
- Cloud sync
- Search

### Exit Criteria
- App is daily usable
- Zero crashes
- Clean UX

## PHASE 2 — Organization & Usability
**Goal**: Make ideas findable and meaningful.

### Features
- Mark idea as:
    - Draft
    - Favorite
    - Final
- Global song search (e.g. by title)

### Technical Focus
- NSPredicate filtering
- SwiftUI .searchable
- Performance with audio lists

### Exit Criteria
- Large song library remains manageable
- UX feels “intentional”, not messy

## PHASE 3 — Collaboration v1
**Goal**: Let multiple people collaborate on the same songs.

### Features
- People can create a band and invite other members
- Invite collaborator via link
- Shared song access

### Technical Focus
- CloudKit
- CloudKit Sharing
- Conflict resolution
- Offline-first sync

