# Polyphonia 🎵

Polyphonia is a dedicated songwriting companion app designed for musicians and bands. It allows you to record musical ideas, organize them by song, and revisit them as your projects evolve. 

Unlike generic voice memo apps, Polyphonia is built specifically for the creative workflow of songwriting—keeping your riffs, melodies, and lyrics structured and accessible.

## 🚀 Current State: Core MVP (Phase 1)

The application is currently in **Phase 1**, focusing on the essential needs of a solo songwriter. The foundational architecture is in place, enabling users to manage songs and recordings locally.

### Key Features
- **Song Management:** Create, rename, and delete songs.
- **Idea Recording:** Record audio clips (riffs, melodies, voice notes) directly within a song project.
- **Timeline:** View a list of audio ideas associated with each song, sorted by date.
- **Playback:** Listen back to recorded ideas.
- **Local Persistence:** All data is saved securely on the device using SwiftData and the local file system.

## 🛠️ Technical Stack

- **Platform:** iOS (SwiftUI)
- **Architecture:** MVVM (Model-View-ViewModel)
- **Concurrency:** Swift 6 Strict Concurrency (`async/await`, `@MainActor`)
- **Persistence:** SwiftData (Schema V1)
- **Audio:** AVFoundation (Recorder & Player services)
- **Minimum Target:** iOS 17.0+

## 📂 Project Structure

The project follows a modular, feature-based architecture to ensure scalability:

```
Polyphonia/
├── App/                # App entry point and global configuration
├── Core/               # Shared logic and infrastructure
│   ├── Audio/          # AVFoundation services (Recorder, Player)
│   ├── Models/         # SwiftData models (Song, AudioIdea)
│   └── Services/       # Data services
├── Features/           # Feature-specific modules (MVVM)
│   ├── SongsList/      # Home screen: List of all songs
│   ├── SongDetail/     # Song view: Timeline of audio ideas
│   └── Recording/      # Audio recording interface
└── Resources/          # Assets and localization
```

## 🗺️ Roadmap

### Phase 2: Organization & Usability (Next Up)
Focus on making large libraries of ideas manageable.
- [ ] **Idea Status:** Mark ideas as "Draft", "Favorite", or "Final".
- [ ] **Search:** Global search by song title.
- [ ] **Filtering:** Filter ideas within a song or globally.
- [ ] **Polished UX:** Enhanced animations and transitions.

### Phase 3: Collaboration
Enabling bands to write together.
- [ ] **CloudKit Sync:** Sync data across user devices.
- [ ] **Sharing:** Invite collaborators to work on songs.
- [ ] **Conflict Resolution:** Handle simultaneous edits.

## 🏃‍♂️ Getting Started

1. Clone the repository.
2. Open `Polyphonia.xcodeproj` in Xcode 15+ (Swift 5.9+ / Swift 6 support required).
3. Ensure the target is set to your device or simulator (iOS 17.0+).
4. Run the app (`Cmd + R`).

---
*Created by Michele Coppola*
