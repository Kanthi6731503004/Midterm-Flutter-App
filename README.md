# Smart Class Check-in & Learning Reflection App

A Flutter mobile application for university class attendance tracking and learning reflection.

## Features

- **GPS-verified check-in** — Records student location at check-in and class end
- **QR Code scanning** — Verifies classroom identity via QR code
- **Pre-class reflection** — Students report previous topic, expected topic, and mood (1–5 emoji scale)
- **Post-class reflection** — Students summarize what they learned and provide feedback
- **Local storage** — All data saved locally via SQLite
- **Session tracking** — View history of all check-in/finish sessions on the home screen

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| GPS | `geolocator` |
| QR Scanner | `mobile_scanner` |
| Local Storage | `sqflite` (SQLite) |
| Cloud | Firebase Firestore (optional) |
| Hosting | Firebase Hosting |

## Setup Instructions

### Prerequisites
- Flutter SDK (3.11+)
- Android Studio or VS Code with Flutter extension
- An Android device/emulator or Chrome (for web)

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# Android
flutter run

# Web (Chrome)
flutter run -d chrome
```

### Build for Web

When building for the web, you **must** copy the SQLite WebAssembly and Service Worker files into the build directory so the local database can function in the browser securely.

```bash
# 1. Build the Flutter Web App
flutter build web

# 2. Inject Web Workers for SQLite Support (Windows syntax)
Copy-Item -Path "web\sqflite_sw.js" -Destination "build\web\"
Copy-Item -Path "web\sqlite3.wasm" -Destination "build\web\"
```

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── checkin_record.dart        # Data model
├── screens/
│   ├── home_screen.dart           # Home with actions + session history
│   ├── checkin_screen.dart        # GPS → QR → pre-class form
│   └── finish_class_screen.dart   # GPS → QR → post-class form
└── services/
    ├── database_service.dart      # SQLite CRUD operations
    └── location_service.dart      # GPS location wrapper
```

## Firebase Configuration & CI/CD Deployment

This project uses **Firebase Hosting** to serve the Flutter Web app, and **GitHub Actions** for automated CI/CD deployments.

### 1. Manual Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Initialize Firebase Hosting in the root directory:
   ```bash
   firebase init hosting
   ```
3. Set the public directory to `build/web`.
4. Run `firebase deploy --only hosting` to push manually.

### 2. Automated GitHub Actions Deployments
This repo is configured to automatically build and deploy the web app whenever code is pushed to the `main` branch.

**The Workflow (`.github/workflows/firebase-hosting-merge.yml`) does the following:**
1. Checks out the repository.
2. Sets up the Flutter environment via `subosito/flutter-action`.
3. Compiles the Flutter Web build (`flutter build web`).
4. **Crucially:** Copies the `sqlite3.wasm` and `sqflite_sw.js` workers into the `build/web/` directory so local storage works in production.
5. Deploys the built artifact to Firebase Hosting.

*Note: The app relies exclusively on SQLite for ultimate reliability and instantaneous local saves, entirely bypassing Cloud Firestore network latency and permission issues.*

## Screens

1. **Home Screen** — Welcome card, Check-in/Finish Class buttons, recent session list
2. **Check-in Screen** — 3-step flow: GPS capture → QR scan → reflection form
3. **Finish Class Screen** — Select active session → GPS → QR → post-class form


