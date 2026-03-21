<div align="center">

# 🎓 Attenly
### A privacy-first, high-performance attendance & schedule architect for students.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?logo=dart&logoColor=white)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blue.svg)](https://riverpod.dev/)
[![Hive](https://img.shields.io/badge/Hive-NoSQL%20Database-orange.svg)](https://docs.hivedb.dev/)
[![Offline First](https://img.shields.io/badge/Architecture-Offline_First-success)](#)

**[📥 Download Latest APK (Android)](#-download--installation)**

</div>

---

## 📌 Overview

**Attenly** is a robust, UX-driven attendance management system designed for the modern student. Engineered with a **strict offline-first philosophy**, the application ensures zero reliance on cloud services, absolute data privacy, and a blazing-fast user experience. 

Built natively with **Flutter** and utilizing **Hive NoSQL** for local persistence, Attenly actively targets the friction points in a student's daily routine: tracking attendance margins, automated class reminders, and ad-free productivity.

## ✨ Core Features & Technical Selling Points

*   **🛡️ 100% Offline & Privacy-First Architecture**: Operations run entirely on-device via **Hive NoSQL Key-Value Store**. No data harvesting, no backend dependencies, and instantaneous CRUD operations.
*   **🚫 Ad-Free & Distraction-Free**: A pure utility application designed exclusively for student productivity.
*   **⚡ Reactive State Management**: implemented using **Riverpod (2.0)** to provide a deterministic, testable, and highly responsive UI.
*   **📊 Advanced Visual Analytics**: Integrated data visualization (via `fl_chart`) offering deep insights into attendance trends, subject-wise performance margins, and goal tracking.
*   **⏰ Automated Background Schedulers**: Utilizing strict exact alarm permissions and native Android background execution for accurate, pre-class local notifications.
*   **📱 Platform Agnostic UI/UX**: Custom Material 3 design system with fluid micro-animations spanning across the entire navigation lifecycle (`go_router`).

---

## 📥 Download & Installation

The application is built to run cross-platform. You can download the pre-compiled binaries from the **[Releases](#)** tab or via the direct links below.

### 🤖 Android
*   **[Download Attenly APK (v1.0.0)](releases/attenly-v1.0.0.apk)**

*(Note: Go to the GitHub repository's `releases` folder to find the generated APK).*

### 🍎 iOS / Windows / macOS / Linux
*Currently, you will need to clone and build from source for these platforms due to iOS signing requirements.*

---

## 🛠️ Tech Stack & Architecture

Attenly implements an adaptation of **Feature-First Clean Architecture** with layered boundaries logic:

| Layer | Responsibility | Technologies Used |
| :--- | :--- | :--- |
| **Presentation** | UI, Animations, ViewModels | `flutter`, `go_router`, `fl_chart`, `google_fonts` |
| **Domain** | Business Logic, Entities, UseCases | Pure `Dart` |
| **Data** | Persistence, DTOs, Local Storage | `hive`, `hive_flutter`, `path_provider` |
| **State** | Dependency Injection, Reactivity | `flutter_riverpod`, `hooks_riverpod` |
| **Platform** | OS Integrations (Alarms, Notifications) | `flutter_local_notifications`, `permission_handler` |

---

## 🚀 Getting Started (Build from Source)

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.11.3 or higher)
*   Dart SDK (comes with Flutter)
*   Android Studio / Xcode for emulators and compilation.

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/attenly_app.git
   cd attenly_app
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters & Freezed Classes (if applicable):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🏗️ Generating Production APK

To compile an optimized, minified, and release-ready APK:

```bash
# Clean previous build artifacts
flutter clean

# Get fresh dependencies
flutter pub get

# Build the release APK with split-per-abi for size optimization
flutter build apk --release --split-per-abi
```
*The output APKs will be located at `build/app/outputs/flutter-apk/`.*

---

## 🤝 Contributing Guidelines

We welcome pull requests! If you're looking to contribute to Attenly:

1. **Fork the Project**
2. **Create your Feature Branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your Changes** following [Conventional Commits](https://www.conventionalcommits.org/) (`git commit -m 'feat: Add some AmazingFeature'`)
4. **Push to the Branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Code Standards
*   Ensure zero warnings from `flutter analyze`.
*   Maintain the current state management pattern (Riverpod).
*   Format code using `dart format .` before pushing.

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.
