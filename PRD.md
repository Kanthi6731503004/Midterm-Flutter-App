# Product Requirement Document (PRD)

## Smart Class Check-in & Learning Reflection App

**Course:** 1305216 Mobile Application Development  
**Date:** 13 March 2026  
**Version:** 1.0

---

## Problem Statement

Universities struggle to verify that students are genuinely present and engaged in class. Traditional paper sign-in sheets are easy to forge, and passive attendance systems cannot measure student engagement or learning reflection. This app solves both problems by combining GPS-verified location, QR code scanning, and a structured learning reflection form — ensuring both physical presence and active participation are recorded.

---

## Target Users

| User | Description |
|------|-------------|
| **Students** | Primary users who check in and reflect on each class session |
| **Instructors** | Secondary users who can review attendance and reflection data |

---

## Feature List

### Check-in (Before Class)
- One-tap **Check-in** button
- Automatic **GPS location** capture and timestamp recording
- **QR Code scanning** to verify classroom identity
- Pre-class reflection form:
  - Topic covered in the **previous class**
  - Topic the student **expects to learn today**
  - **Mood rating** (1–5 emoji scale)

### Finish Class (After Class)
- One-tap **Finish Class** button
- Automatic **GPS location** capture
- **QR Code scanning** to confirm class end
- Post-class reflection form:
  - **What they learned** today (short text)
  - **Feedback** about the class or instructor

---

## User Flow

```
[App Launch]
     │
     ▼
[Home Screen]
 ┌───┴───┐
 │       │
[Check-in]   [Finish Class]
 │               │
[GPS + QR]   [GPS + QR]
 │               │
[Pre-class   [Post-class
 Form]         Form]
 │               │
[Save to      [Save to
 Storage]      Storage]
```

---

## Data Fields

### Check-in Record
| Field | Type | Description |
|-------|------|-------------|
| `session_id` | String | Unique ID per check-in session |
| `student_id` | String | Student identifier |
| `checkin_time` | DateTime | Timestamp of check-in |
| `checkin_lat` | Double | GPS latitude at check-in |
| `checkin_lng` | Double | GPS longitude at check-in |
| `qr_code_value` | String | Value scanned from QR code |
| `previous_topic` | String | Topic from previous class |
| `expected_topic` | String | Expected topic for today |
| `mood_before` | Int (1–5) | Mood rating before class |

### Finish Class Record
| Field | Type | Description |
|-------|------|-------------|
| `session_id` | String | Links to check-in session |
| `finish_time` | DateTime | Timestamp of class end |
| `finish_lat` | Double | GPS latitude at finish |
| `finish_lng` | Double | GPS longitude at finish |
| `learned_today` | String | Summary of what was learned |
| `feedback` | String | Feedback on class/instructor |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **GPS** | `geolocator` package |
| **QR Scanner** | `mobile_scanner` package |
| **Local Storage** | `sqflite` (SQLite) |
| **Cloud Database** | Firebase Firestore |
| **Hosting** | Firebase Hosting (Flutter Web) |
| **Auth (optional)** | Firebase Authentication |

---

## Technical Architecture

The application follows a clean layered architecture pattern:

### 1. Presentation Layer (UI)
- **State Management**: Built-in Flutter `setState` scoped to stateful widgets.
- **UI Components**: Custom reusable cards, styled forms, and multi-step `Stepper` navigation.
- **Design System**: Global `ThemeData` enforcing Google Fonts (Outfit), vibrant glassmorphism gradients, and elevated shadows.

### 2. Service Layer (Business Logic)
- `DatabaseService`: Singleton pattern handling all asynchronous CRUD operations to the local database.
- `LocationService`: Utility wrapper around `geolocator` ensuring safe permission requests and timeout handling.

### 3. Data Access Layer
- `sqflite` implementation handling raw SQL transactions.
- Web support provided via `sqflite_common_ffi_web` injected WebAssembly workers (`sqlite3.wasm`).

---

## Security & Edge Cases
- **Missing Permissions**: The app gracefully catches denied Camera or Location permissions and provides clear SnackBar error messages without crashing.
- **Fake Check-ins**: By enforcing real-time GPS coordinates and requiring physical QR scans, the app prevents students from spoofing their attendance remotely.
- **Offline Reliability**: The decision to rely fully on SQLite ensures that students in classrooms with poor Wi-Fi or cellular dead-zones can still complete their check-ins instantly.

---

## UI/UX Guidelines
- **Color Palette**: Primary Indigo (`#6C63FF`), Success Teal (`#00B894`), Alert Red (`#FF6B6B`), Warning Yellow (`#FDCB6E`).
- **Typography**: Google Fonts "Outfit" for excellent legibility on mobile devices.
- **Interaction**: All network and database calls show loading spinners on primary action buttons to prevent duplicate submissions.
- **Feedback**: Instant visual SnackBars (`✅ Done` or `❌ Error`) confirm every critical action.

---

## Minimum Viable Screens

1. **Home Screen** — Entry point with Check-in and Finish Class actions, plus a dynamic list of recent sessions sorted by newest first.
2. **Check-in Screen** — 3-step vertical stepper: GPS validation → QR Camera Detection → Pre-class learning reflection form.
3. **Finish Class Screen** — Active session selector → GPS exit validation → QR Camera Detection → Post-class pedagogical feedback form.

---

## Out of Scope (MVP)

- Real-time instructor dashboard
- Push notifications
- Biometric verification
- Offline sync when GPS is unavailable
