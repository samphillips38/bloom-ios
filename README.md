# Bloom iOS

Native iOS client for the Bloom learning platform, built with SwiftUI. Provides an interactive, course-based learning experience inspired by Brilliant.

## Tech Stack

- **UI:** SwiftUI
- **Architecture:** MVVM with `@EnvironmentObject` for global state
- **Networking:** URLSession async/await
- **Auth Storage:** Keychain via `KeychainHelper`
- **Min Target:** iOS 16+

## Project Structure

```
Bloom/
├── App/
│   ├── BloomApp.swift           # App entry point & root view
│   └── AppState.swift           # Global auth & user state (ObservableObject)
├── Core/
│   ├── Auth/
│   │   ├── AuthManager.swift    # Login, register & token management
│   │   └── KeychainHelper.swift # Secure token storage
│   ├── Network/
│   │   ├── APIClient.swift      # Generic async HTTP client
│   │   └── Endpoints.swift      # API endpoint definitions
│   └── Theme/
│       ├── Animations.swift     # Shared animation constants
│       ├── Colors.swift         # App color palette
│       ├── Components.swift     # Reusable UI components
│       └── Fonts.swift          # Typography definitions
├── Features/
│   ├── Auth/        → AuthView           # Login & registration screen
│   ├── Home/        → HomeView           # Dashboard with streaks & recommended courses
│   ├── Courses/     → CoursesView        # Browse all courses by category
│   ├── CourseDetail/ → CourseDetailView   # Course overview with levels & lessons
│   ├── Lesson/      → LessonView         # Interactive lesson content player
│   ├── Main/        → MainTabView        # Tab bar (Home, Courses, Premium, Profile)
│   ├── Premium/     → PremiumView        # Premium subscription screen
│   └── Profile/     → ProfileView        # User profile & settings
├── Models/
│   ├── Course.swift             # Course, Level, Lesson models
│   ├── Lesson.swift             # Lesson content & content data types
│   ├── Progress.swift           # User progress model
│   └── User.swift               # User & auth response models
└── Resources/
    └── Assets.xcassets           # App icons & color assets
```

## App Flow

1. **Launch** → `AppState` checks Keychain for an existing auth token
2. **Unauthenticated** → `AuthView` (login / register)
3. **Authenticated** → `MainTabView` with four tabs:
   - **Home** — Streak stats, energy, recommended courses, continue learning
   - **Courses** — Browse all courses grouped by category
   - **Premium** — Subscription upsell
   - **Profile** — User info and settings
4. **Course Detail** — Tap a course to see levels and lessons
5. **Lesson** — Interactive content player with text, images, and quiz questions

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 16+ simulator or device

### Setup

1. Open `Bloom.xcodeproj` in Xcode
2. Update the API base URL in `Bloom/Core/Network/Endpoints.swift`:
   ```swift
   static let baseURL = "http://localhost:3000/api"
   ```
3. Build and run on a simulator or device (⌘R)

> **Note:** The API server ([bloom-api](https://github.com/samphillips38/bloom-api)) must be running for the app to function.
