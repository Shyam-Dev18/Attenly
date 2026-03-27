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

- **🛡️ 100% Offline & Privacy-First Architecture**: Operations run entirely on-device via **Hive NoSQL Key-Value Store**. No data harvesting, no backend dependencies, and instantaneous CRUD operations.
- **🚫 Ad-Free & Distraction-Free**: A pure utility application designed exclusively for student productivity.
- **⚡ Reactive State Management**: implemented using **Riverpod (2.0)** to provide a deterministic, testable, and highly responsive UI.
- **📊 Advanced Visual Analytics**: Integrated data visualization (via `fl_chart`) offering deep insights into attendance trends, subject-wise performance margins, and goal tracking.
- **⏰ Automated Background Schedulers**: Utilizing strict exact alarm permissions and native Android background execution for accurate, pre-class local notifications.
- **📱 Platform Agnostic UI/UX**: Custom Material 3 design system with fluid micro-animations spanning across the entire navigation lifecycle (`go_router`).

---

## 📥 Download & Installation

### 🤖 Android (Recommended)

**⭐ [Download Latest APK (ARM64)](https://github.com/Shyam-Dev18/Attenly/raw/main/attenly_app/releases/attenly-v1.1.1-arm64.apk)**

The app provides optimized APKs for different device architectures:

| Architecture               | File                    | Best For                       |
| -------------------------- | ----------------------- | ------------------------------ |
| **ARM64** (⭐ Recommended) | `attenly-v*.apk`        | 99% of modern Android phones   |
| **ARM v7**                 | `attenly-v*-armv7.apk`  | Older 32-bit Android devices   |
| **x86_64**                 | `attenly-v*-x86_64.apk` | Android emulators, x86 tablets |

Direct download links:

- [attenly-v1.1.1-arm64.apk](https://github.com/Shyam-Dev18/Attenly/raw/main/releases/attenly-v1.1.1-arm64.apk)
- [attenly-v1.1.1-armv7.apk](https://github.com/Shyam-Dev18/Attenly/raw/main/releases/attenly-v1.1.1-armv7.apk)
- [attenly-v1.1.1-x86_64.apk](https://raw.githubusercontent.com/Shyam-Dev18/Attenly/raw/main/releases/attenly-v1.1.1-x86_64.apk)

**For detailed installation instructions**, see [releases/README.md](releases/README.md)

### 🍎 iOS / Windows / macOS / Linux

_Currently, you will need to clone and build from source for these platforms due to iOS signing requirements._

---

## 🛠️ Tech Stack & Architecture

Attenly implements an adaptation of **Feature-First Clean Architecture** with layered boundaries logic:

| Layer            | Responsibility                          | Technologies Used                                   |
| :--------------- | :-------------------------------------- | :-------------------------------------------------- |
| **Presentation** | UI, Animations, ViewModels              | `flutter`, `go_router`, `fl_chart`, `google_fonts`  |
| **Domain**       | Business Logic, Entities, UseCases      | Pure `Dart`                                         |
| **Data**         | Persistence, DTOs, Local Storage        | `hive`, `hive_flutter`, `path_provider`             |
| **State**        | Dependency Injection, Reactivity        | `flutter_riverpod`, `hooks_riverpod`                |
| **Platform**     | OS Integrations (Alarms, Notifications) | `flutter_local_notifications`, `permission_handler` |

---

## 🚀 Getting Started (Build from Source)

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.11.3 or higher)
- Dart SDK (comes with Flutter)
- Android Studio / Xcode for emulators and compilation.

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

## 🏗️ Building & Releasing APKs

### Quick Build (Development)

To compile a debug APK for testing:

```bash
flutter build apk --debug
```

### Production Release APK

For optimized, minified, and release-ready APKs with architecture-specific builds:

**On Linux/macOS:**

```bash
chmod +x scripts/build_release.sh
./scripts/build_release.sh
```

**On Windows:**

```bash
scripts\build_release.bat
```

This builds and organizes optimized APKs for multiple architectures. The script will:

- ✅ Build optimized Release APKs for ARM64, ARM v7, and x86_64
- ✅ Rename and organize files into `releases/v{VERSION}/`
- ✅ Generate SHA256 checksums for verification
- ✅ Create release info documentation

### Publishing Releases to GitHub

Once you have built the APKs locally or through GitHub Actions:

1. **Create a git tag** matching your version:

   ```bash
   git tag v1.2.0
   git push origin v1.2.0
   ```

2. **GitHub Actions** will automatically:
   - Detect the new tag
   - Build the APKs
   - Create a release and upload APKs as release assets

3. **Users can download** from the [Releases](https://github.com/Shyam-Dev18/Attenly/releases) page

**For detailed install instructions**, see [releases/README.md](releases/README.md)

---

## 📂 Release Folder Structure

After building releases, the folder structure looks like:

```
releases/
├── README.md                          (Installation guide for users)
├── v1.1.1/                            (Version-specific folder)
│   ├── attenly-v1.1.1-arm64.apk      (ARM64 - Modern phones)
│   ├── attenly-v1.1.1-armv7.apk      (ARM v7 - Older 32-bit devices)
│   ├── attenly-v1.1.1-x86_64.apk     (x86_64 - Emulators & tablets)
│   ├── checksums.sha256              (File integrity hashes)
│   └── RELEASE_INFO.md               (Build metadata & sizes)
├── v1.2.0/                            (New releases follow same pattern)
└── (other versions...)
```

### Files Generated by Build Scripts

- **`attenly-v{VERSION}-*.apk`** - Architecture-specific APK files
- **`checksums.sha256`** - SHA256 hashes for integrity verification
- **`RELEASE_INFO.md`** - Release metadata including sizes and checksums

Users download from GitHub Releases tab, which contains these APKs automatically when you push a git tag.

---

## 🤝 Contributing Guidelines

We welcome pull requests! If you're looking to contribute to Attenly:

1. **Fork the Project**
2. **Create your Feature Branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your Changes** following [Conventional Commits](https://www.conventionalcommits.org/) (`git commit -m 'feat: Add some AmazingFeature'`)
4. **Push to the Branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Code Standards

- Ensure zero warnings from `flutter analyze`.
- Maintain the current state management pattern (Riverpod).
- Format code using `dart format .` before pushing.

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.
