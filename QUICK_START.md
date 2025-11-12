# 🚀 Quick Start Guide - LaporJTI

Panduan cepat untuk mulai development aplikasi LaporJTI.

## Prerequisites

Pastikan sudah terinstall:
- Flutter SDK (3.x atau lebih baru)
- Android Studio / VS Code
- Android SDK / iOS SDK
- Git

## Setup Project

### 1. Clone & Install Dependencies

```bash
# Navigate ke folder project
cd "d:\COOLYEAH\PEM MOBILE\PBL\laporin"

# Install dependencies
flutter pub get

# Check setup
flutter doctor
```

### 2. Run Aplikasi

**Untuk Android Emulator:**
```bash
# Start emulator dari Android Studio
# Atau jalankan command:
flutter run
```

**Untuk Chrome (Web):**
```bash
flutter run -d chrome
```

**Untuk Physical Device:**
```bash
# Enable USB Debugging di device
# Connect via USB
flutter run
```

## 📱 Testing Flow

### 1. First Launch
- App akan show **Splash Screen** (3 detik)
- Redirect ke **Onboarding Screen**

### 2. Onboarding
- Swipe 3 halaman atau klik "Lanjut"
- Klik "Lewati" untuk skip
- Klik "Mulai" di halaman terakhir

### 3. Login
- **Email**: Masukkan email valid (e.g., `test@mail.com`)
- **Password**: Minimal 6 karakter (e.g., `password123`)
- Klik "Masuk"

### 4. Register (Optional)
- Klik "Daftar Sekarang" dari Login Screen
- Isi form:
  - Nama Lengkap
  - Email
  - Password
  - Konfirmasi Password
- Centang Terms & Conditions
- Klik "Daftar"

### 5. Home Screen
- Explore menu (placeholder)
- Test logout dari icon di AppBar

## 🔧 Development Workflow

### Hot Reload
Saat development, save file untuk trigger hot reload:
- **VS Code**: `Ctrl + S` / `Cmd + S`
- **Android Studio**: `Ctrl + S` / `Cmd + S`
- **Terminal**: Tekan `r`

### Hot Restart
Untuk restart app dari awal:
- **Terminal**: Tekan `R`
- **VS Code**: `Ctrl + Shift + P` → "Flutter: Hot Restart"

### Debug Console
```bash
# Lihat logs
flutter logs

# Clear cache
flutter clean
flutter pub get
```

## 📂 File Penting

### Yang Sering Diedit:
```
lib/
├── screens/           # Untuk tambah/edit UI screens
├── providers/         # Untuk tambah/edit state management
├── routes/            # Untuk tambah routes baru
└── constants/         # Untuk edit colors/text styles
```

### Configuration:
```
pubspec.yaml          # Dependencies & assets
analysis_options.yaml # Lint rules
```

## 🎨 Menambahkan Gambar

1. **Copy gambar** ke `assets/images/`
2. **Update pubspec.yaml** (sudah di-setup)
3. **Gunakan di code**:
```dart
Image.asset('assets/images/logo.png')
```

## 🔌 Menambahkan Package

1. **Tambahkan ke pubspec.yaml**:
```yaml
dependencies:
  new_package: ^1.0.0
```

2. **Install**:
```bash
flutter pub get
```

3. **Import di code**:
```dart
import 'package:new_package/new_package.dart';
```

## 🐛 Troubleshooting

### Error: "Waiting for another flutter command..."
```bash
# Kill proses Flutter
taskkill /F /IM dart.exe
# Atau restart IDE
```

### Error: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "No devices found"
```bash
# Check devices
flutter devices

# Restart ADB (Android)
adb kill-server
adb start-server
```

### Hot Reload tidak jalan
```bash
# Hot restart
flutter run

# Atau rebuild
flutter clean
flutter pub get
flutter run
```

## 📝 Common Tasks

### Menambahkan Screen Baru

1. **Buat file** di `lib/screens/`:
```dart
// lib/screens/new_screen.dart
import 'package:flutter/material.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Screen')),
      body: Center(child: Text('Hello!')),
    );
  }
}
```

2. **Tambahkan route** di `lib/routes/app_router.dart`:
```dart
GoRoute(
  path: '/new',
  name: 'new',
  builder: (context, state) => const NewScreen(),
),
```

3. **Navigate** dari screen lain:
```dart
context.push('/new');
```

### Menambahkan Provider Baru

1. **Buat file** di `lib/providers/`:
```dart
// lib/providers/new_provider.dart
import 'package:flutter/foundation.dart';

class NewProvider with ChangeNotifier {
  String _data = '';
  
  String get data => _data;
  
  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}
```

2. **Register** di `main.dart`:
```dart
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => NewProvider()),
  ],
)
```

3. **Gunakan** di widget:
```dart
// Read
context.read<NewProvider>().updateData('new value');

// Watch
final data = context.watch<NewProvider>().data;
```

## 🎯 Next Development Steps

### Fase 2: Backend Integration
1. Setup API client (Dio)
2. Create API service files
3. Update providers dengan API calls
4. Handle authentication tokens

### Fase 3: Report Features
1. Create report form screen
2. Image picker integration
3. Report list screen
4. Report detail screen

### Fase 4: Polish
1. Error handling improvements
2. Loading states
3. Animations
4. Testing

## 📚 Resources

### Documentation
- [README.md](README.md) - Overview
- [SUMMARY.md](SUMMARY.md) - Detailed summary
- [docs/PROVIDER_GUIDE.md](docs/PROVIDER_GUIDE.md) - Provider guide
- [docs/ROUTING_GUIDE.md](docs/ROUTING_GUIDE.md) - Routing guide
- [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) - Project structure

### External Links
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [go_router Package](https://pub.dev/packages/go_router)
- [Google Fonts](https://pub.dev/packages/google_fonts)

## 💡 Tips

1. **Gunakan VS Code Extensions**:
   - Flutter
   - Dart
   - Flutter Widget Snippets
   - Error Lens

2. **Keyboard Shortcuts**:
   - `Ctrl + Space`: Auto-complete
   - `F2`: Rename symbol
   - `Alt + Shift + F`: Format document
   - `Ctrl + .`: Quick fixes

3. **Debugging**:
   - Set breakpoints di code
   - Gunakan `print()` untuk logging
   - Check Flutter DevTools

4. **Performance**:
   - Use `const` constructors
   - Avoid rebuilding entire tree
   - Profile dengan Flutter DevTools

## ✅ Checklist Sebelum Commit

- [ ] `flutter analyze` - No errors
- [ ] `flutter test` - All tests pass
- [ ] Code formatted (`flutter format lib/`)
- [ ] No debug `print()` statements
- [ ] Comments untuk code yang complex
- [ ] Update documentation jika perlu

---

**Happy Coding! 🚀**

Butuh bantuan? Cek dokumentasi lengkap di folder `docs/`!
