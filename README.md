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
```bash
flutter build web
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

## Firebase Configuration

To enable Firebase features:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add your app (Android/Web) and download config files
3. For Android: place `google-services.json` in `android/app/`
4. For Web: update `web/index.html` with Firebase config
5. Run `flutterfire configure` if using FlutterFire CLI

The app works fully offline with SQLite even without Firebase configured.

## Screens

1. **Home Screen** — Welcome card, Check-in/Finish Class buttons, recent session list
2. **Check-in Screen** — 3-step flow: GPS capture → QR scan → reflection form
3. **Finish Class Screen** — Select active session → GPS → QR → post-class form

---

## AI Usage Report

- **AI Tools Used:** Gemini (Antigravity coding assistant)
- **AI Generated:** Flutter UI scaffolding, SQLite database service, GPS location service, QR scanner integration, data model structure, project configuration
- **Manually Modified/Implemented:** Firebase project setup, deployment configuration, testing on device
