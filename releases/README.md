# Attenly APK Releases

## Version 1.1.1 - Optimized Split APKs

We provide different APK versions optimized for different device architectures:

### Recommended Downloads

- **ARM64 (`attenly-v1.1.1-arm64.apk`)** - **19 MB** ⭐ **RECOMMENDED**
  - For most modern Android devices (99% of devices)
  - Best performance and compatibility
  - Download this if unsure

- **ARM v7 (`attenly-v1.1.1-armv7.apk`)** - 16.5 MB
  - For older 32-bit Android devices
  - Smallest file size
  - Devices released before 2015

- **x86/x86_64 (`attenly-v1.1.1-x86_64.apk`)** - 20.5 MB
  - For Android emulators and x86-based tablets
  - Not for general use

### How to Determine Your Device Architecture

1. Open **Settings** → **About Phone**
2. Look for "Processor" or "Chipset" info
3. Most modern devices: **Qualcomm Snapdragon** or **MediaTek** (use ARM64)
4. Older devices or x86: Check specific model specs

### All Versions

| Version                   | Architecture | File Size | Best For               |
| ------------------------- | ------------ | --------- | ---------------------- |
| attenly-v1.1.1-arm64.apk  | ARM64 (v8)   | 19 MB     | Modern Android phones  |
| attenly-v1.1.1-armv7.apk  | ARM v7       | 16.5 MB   | Older Android devices  |
| attenly-v1.1.1-x86_64.apk | x86_64       | 20.5 MB   | Emulators              |
| attenly-v1.0.0.apk        | Universal    | 57 MB     | Fallback universal APK |

### Installation Instructions

1. Download the appropriate APK for your device
2. Enable "Unknown Sources" in Settings → Security
3. Open the downloaded APK and tap "Install"
4. Grant necessary permissions when prompted

### Build Information

- **Dart Version**: 3.11.3+
- **Flutter Engine**: Optimized with code obfuscation
- **Size Optimization**: R8 minification + resource shrinking + ABI splitting
- **Signing**: Official signed release with RSA 2048-bit keystore

---

**Latest Release**: v1.1.1 (March 28, 2026)
