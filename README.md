# Quran Library

<p align="center">
<img src="assets/images/logo_gran.png" width="200"/>
</p>

<!-- Badges -->




An integrated Flutter package for the Holy Qur’an (Madinah Mushaf - Hafs narration) with advanced features including audio recitations, tafsir, prayer times, Qiblah, Hadith, and more.

> [!IMPORTANT]
> Please set `useMaterial3: false` in your `ThemeData` to avoid any formatting issues with the Quranic fonts.

---

## 🌟 Features

- **📖 Holy Quran**: High-quality display identical to the Madinah Mushaf.
- **🎧 Audio Recitations**: Support for multiple world-renowned reciters with background playback.
- **📚 Tafsir & Translations**: Multiple interpretations and translations available for download.
- **🕌 Prayer Times**: Accurate calculation based on location with Azan notification support.
- **🧭 Qiblah Finder**: Precise Qiblah direction using device sensors.
- **📜 Hadith Library**: Access to Sahih Bukhari and Sahih Muslim.
- **📿 Dhikr & Duaa**: Collection of morning/evening azkar and various supplications.
- **🔍 Advanced Search**: Search by ayah, surah, or juz.
- **🔖 Bookmarks**: Save and organize your progress.
- **🌓 Dark Mode**: Fully compatible with light and dark themes.

---

## 🚀 Getting Started

### 1. Installation

Add `quran_library` to your `pubspec.yaml`:

```yaml
dependencies:
  quran_library: ^3.0.0
```

### 2. Platform Setup

#### Android
The package automatically handles required permissions. For system-integrated audio controls, your `MainActivity` must extend `AudioServiceActivity`.

**Kotlin:**
```kotlin
import com.ryanheise.audioservice.AudioServiceActivity
class MainActivity: AudioServiceActivity()
```

#### iOS
Add background audio mode to your `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

#### macOS
Enable network access in `DebugProfile.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

### 3. Initialization

```dart
void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await QuranLibrary.init(); // Initialize the library
  runApp(MyApp());
}
```

---

## 🛠 Usage

### Quran Home Screen
The easiest way to integrate the full Quran experience:

```dart
QuranLibraryScreen(
  parentContext: context,
  isDark: true,
  // Many more customization options available
)
```

### Prayer Times
```dart
PrayerTimesScreen(isDark: false)
```

### Qiblah Finder
```dart
QiblahScreen(isDark: false)
```

### Hadith Library
```dart
HadithScreen(isDark: false)
```

### Dhikr & Duaa
```dart
DhikrReminderScreen(isDark: false)
// or
DuaaScreen(isDark: false)
```

---

## 📖 Documentation



## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Developed with ❤️ by <a href="https://github.com/mohamed12150">mohamed12150</a>
</p>
