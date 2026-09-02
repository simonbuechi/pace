# Pace Amigo

> **Clean and simple, yet unmistakably playful focus & interval timer for Web, iOS, and Android.**

Pace Amigo balances razor-sharp utility with tactile joy. Designed to work consistently across platforms (Web, iOS, Android, and Desktop), it combines clean typography, fluid interval visualizers, ambient audio cues, and responsive cross-platform storage.

---

## 🎨 Design System

Pace Amigo features a signature diagonal gradient (`#9025A7` amethyst purple to `#D81860` electric magenta), bouncy spring physics, and organic micro-interactions.

See the complete design specification in [DESIGN.md](DESIGN.md).

---

## 📱 Platforms Supported

- **Web**: Responsive layout with modern PWA capabilities, Web Audio, and IndexedDB persistence.
- **iOS**: Native Cupertino integration, background audio & interval timing.
- **Android**: Material 3 theming, notification channel alerts, and adaptive icons.

---

## 🚀 Getting Started

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- Google Chrome or Edge for Web testing
- Android Studio / Xcode (optional, for mobile targets)

### 2. Environment Setup

Copy `.env.example` to `.env` in the project root:

```bash
cp .env.example .env
```

Configure your Firebase Web backend parameters:

```env
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project_id.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id
```

> **Security Note**: `.env` is ignored by git (`.gitignore`) to keep credentials private.

---

## 🌐 Running & Testing the Web Version

### Development Mode (with Hot Reload)

To launch the app directly in Google Chrome:

```bash
flutter run -d chrome
```

Or in Microsoft Edge:

```bash
flutter run -d edge
```

Or run headless as a local web server (accessible from any browser or network device):

```bash
flutter run -d web-server --web-port=8080
```

### Production Web Build

To compile an optimized production web bundle:

```bash
flutter build web
```

To preview the production build locally:

```bash
python -m http.server 8080 --directory build/web
```
Then visit `http://localhost:8080`.

---

## 🧪 Testing

Run all unit and widget tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

---

## 🏗️ Architecture

- **State Management**: `flutter_riverpod` (v2)
- **Local Storage**: `hive` & `hive_flutter` (IndexedDB on Web, local NoSQL on mobile)
- **Sound Effects**: `audioplayers` (synthesized interval transition chimes)
- **Design & Typography**: Plus Jakarta Sans (`google_fonts`)
- **Backend / Sync**: Firebase Web Backend (configured via `.env`)
