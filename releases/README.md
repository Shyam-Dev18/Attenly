# Attenly APK Releases

## Download Latest Release

⭐ **Get the latest version from [GitHub Releases](https://github.com/Shyam-Dev18/Attenly/releases)**

---

## About Attenly App

**Attenly** is a smart offline attendance tracker for students. The app allows you to track your attendance offline and sync when connected.

### Version Information

- **Current Version**: 1.1.1
- **Dart/Flutter**: 3.11.3+
- **Build Type**: Release (optimized for production use)

---

## Installation Guide

### Step 1: Determine Your Device Architecture

Run this in your Android device's terminal to check your processor:

```bash
getprop ro.product.cpu.abi
```

Or open **Settings** → **About Phone** and check:

- **Snapdragon/MediaTek/Exynos**: Use **ARM64** (v8)
- **Older devices**: Use **ARM v7** (32-bit)
- **Android Emulator/Tablets (x86)**: Use **x86_64**

### Step 2: Download the Correct APK

| Architecture               | Download Link                                                            | Best For                          | File Size |
| -------------------------- | ------------------------------------------------------------------------ | --------------------------------- | --------- |
| **ARM64 (⭐ RECOMMENDED)** | [Latest Release](https://github.com/Shyam-Dev18/Attenly/releases/latest) | 99% of modern Android phones      | ~19 MB    |
| **ARM v7**                 | [Latest Release](https://github.com/Shyam-Dev18/Attenly/releases/latest) | Older 32-bit Android devices      | ~16.5 MB  |
| **x86_64**                 | [Latest Release](https://github.com/Shyam-Dev18/Attenly/releases/latest) | Android emulators and x86 tablets | ~20.5 MB  |

### Step 3: Install the APK

1. **Enable Unknown Sources** (if not already enabled):
   - Settings → Apps & notifications (or Applications)
   - Advanced → Special app access (or Unknown sources)
   - Enable "Install unknown apps" for your file manager or browser

2. **Open the APK File**:
   - Locate the downloaded APK file
   - Tap to open it
   - Tap "Install" button

3. **Grant Permissions**:
   - The app will request permissions for storage, notifications, etc.
   - Tap "Allow" to grant the necessary permissions

4. **Open the App**:
   - Once installed, tap "Open" or find "Attenly" in your app drawer

---

## What's Included

✅ Offline attendance tracking  
✅ Smart statistics and reports  
✅ Local data storage (no cloud required)  
✅ Export to Excel  
✅ Lightweight (~20 MB)  
✅ Optimized for all Android devices

---

## Build Information

- **Optimization**: R8 code minification + resource shrinking
- **ABI Splitting**: Separate optimized builds for each architecture
- **Code Obfuscation**: Release build includes native code obfuscation
- **Storage**: Uses Hive for local offline data storage

---

## Troubleshooting

### "Not enough storage" error

- Check available phone storage (need ~50 MB free)
- Uninstall unused apps to free up space

### "App not installed" error

- Make sure you downloaded the correct architecture APK
- Try re-downloading the APK file
- Clear browser cache and try again

### "Unknown app" warning

- This is normal for APK files from unknown sources
- Make sure you trust the download source
- Tap "Install anyway" to proceed

### App crashes on startup

- Uninstall the app completely
- Clear app cache: Settings → Apps → Attenly → Clear Cache
- Reinstall the APK file

---

## Release History

### Automated Releases

All releases starting from **v1.1.1** are automatically built and published using GitHub Actions.

**How releases are made:**

1. Create a git tag: `git tag v1.x.x`
2. Push the tag: `git push origin v1.x.x`
3. GitHub Actions automatically:
   - Builds the Flutter app in release mode
   - Creates split APKs for each architecture
   - Generates a GitHub Release
   - Uploads all APKs as release assets

You can download APKs from the [Releases page](https://github.com/Shyam-Dev18/Attenly/releases)

---

## FAQ

**Q: Which APK should I download?**  
A: If unsure, download the **ARM64** version (~19 MB) - it works on 99% of modern phones.

**Q: Is my data safe?**  
A: Yes! Attenly stores all data locally on your device. No data is sent to any server.

**Q: What permissions does the app need?**  
A: Storage (for exports) and Notifications (for reminders).

**Q: Can I use the app offline?**  
A: Yes! The app is fully functional offline. All attendance data is stored locally.

---

## Support

For issues, feature requests, or bug reports, please create an issue on the [GitHub Issues page](https://github.com/Shyam-Dev18/Attenly/issues)

---

**Last Updated**: 2026 | Built with ❤️ using Flutter

- **Signing**: Official signed release with RSA 2048-bit keystore

---

**Latest Release**: v1.1.1 (March 28, 2026)
