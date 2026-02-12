# Polyphonia 🎵

Polyphonia is a dedicated songwriting companion app designed for musicians and bands. It allows you to record musical ideas, organize them by song, and revisit them as your projects evolve. 

Unlike generic voice memo apps, Polyphonia is built specifically for the creative workflow of songwriting—keeping your riffs, melodies, and lyrics structured and accessible.

## 🚀 Current State: Organization & Experience (Phase 2.5)

The application has moved beyond the MVP and now includes robust organization features and an enhanced recording experience.

### Key Features
- **Song Management:** Create, rename, and delete songs.
- **Global Search:** Quickly find songs by title from the main list.
- **Idea Recording:** Record audio clips with real-time visual feedback using radial and wave particle animations.
- **Status Tracking:** Mark audio ideas as **Draft**, **Favorite**, or **Final** to track progress.
- **Audio Import:** Bring in recordings from Voice Memos or the Files app.
- **Timeline:** A structured view of audio ideas per song, sorted by date with visual status badges.
- **Playback:** Integrated player for reviewing ideas directly in the app.
- **Data Persistence:** Robust storage using SwiftData with schema versioning and migration support.

## 🛠️ Technical Stack

- **Platform:** iOS (SwiftUI)
- **Architecture:** MVVM (Model-View-ViewModel)
- **Concurrency:** Swift 6 Strict Concurrency (`async/await`, `@MainActor`)
- **Persistence:** SwiftData (Schema V2 with Migration Plan)
- **Audio:** AVFoundation (Recorder & Player services)
- **Animations:** SwiftUI Canvas & TimelineView for high-performance audio visualizations.
- **Minimum Target:** iOS 17.0+

## 📂 Project Structure

The project follows a modular, feature-based architecture:

```
Polyphonia/
├── App/                # App entry point and global configuration
├── Core/               # Shared logic and infrastructure
│   ├── Audio/          # AVFoundation services (Recorder, Player, Import)
│   ├── Models/         # SwiftData models & Schema versions (V1, V2)
│   └── Services/       # Data services (SongService)
├── Features/           # Feature-specific modules (MVVM)
│   ├── SongsList/      # Home screen: List of all songs + Search
│   ├── SongDetail/     # Song view: Timeline of audio ideas + Import
│   └── Recording/      # Audio recording interface + Visualizations
└── Resources/          # Assets and localization
```

## 🗺️ Roadmap

### ✅ Phase 1: Core MVP
- [x] Song creation and management.
- [x] Basic audio recording and playback.
- [x] Local persistence.

### ✅ Phase 2: Organization & Usability
- [x] **Idea Status:** Mark ideas as "Draft", "Favorite", or "Final".
- [x] **Search:** Global search by song title.
- [x] **Audio Import:** Support for external file importing.

### ✅ Phase 2.5: Recording Experience
- [x] **Radial Visualizations:** Particle animations synchronized with audio levels.
- [x] **Waveform Visuals:** Real-time wave animations during recording.

### 🔜 Phase 3: Collaboration
Enabling bands to write together.
- [ ] **CloudKit Sync:** Sync data across user devices.
- [ ] **Sharing:** Invite collaborators to work on songs.
- [ ] **Conflict Resolution:** Handle simultaneous edits.

## 🏃‍♂️ Getting Started

1. Clone the repository.
2. Open `Polyphonia.xcodeproj` in Xcode 16+ (Swift 6 support required).
3. Ensure the target is set to your device or simulator (iOS 17.0+).
4. Run the app (`Cmd + R`).

---
*Created by Michele Coppola*
