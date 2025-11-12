# Struktur Folder Aplikasi LaporJTI

## Overview
Struktur folder dirancang mengikuti prinsip Clean Architecture dan best practices Flutter.

## Struktur Detail

```
laporin/
├── android/                    # Platform Android specific files
├── ios/                        # Platform iOS specific files
├── linux/                      # Platform Linux specific files
├── macos/                      # Platform macOS specific files
├── web/                        # Platform Web specific files
├── windows/                    # Platform Windows specific files
│
├── assets/                     # Asset files (images, icons, fonts)
│   ├── images/                # Gambar aplikasi
│   │   └── .gitkeep
│   └── icons/                 # Icon aplikasi
│       └── .gitkeep
│
├── lib/                       # Source code aplikasi
│   ├── constants/            # Konstanta aplikasi
│   │   ├── colors.dart       # Definisi warna
│   │   └── text_styles.dart  # Definisi text styles
│   │
│   ├── models/               # Data models
│   │   └── onboarding_model.dart
│   │
│   ├── providers/            # State management providers
│   │   ├── auth_provider.dart
│   │   └── onboarding_provider.dart
│   │
│   ├── routes/               # Routing configuration
│   │   └── app_router.dart
│   │
│   ├── screens/              # UI Screens
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── home_screen.dart
│   │
│   ├── widgets/              # Reusable widgets
│   │   └── (akan diisi sesuai kebutuhan)
│   │
│   └── main.dart            # Entry point aplikasi
│
├── docs/                     # Dokumentasi
│   ├── PROVIDER_GUIDE.md    # Panduan Provider
│   ├── ROUTING_GUIDE.md     # Panduan Routing
│   └── FOLDER_STRUCTURE.md  # File ini
│
├── test/                     # Unit & Widget tests
│   └── widget_test.dart
│
├── analysis_options.yaml     # Lint rules
├── pubspec.yaml             # Dependencies & assets
└── README.md                # Dokumentasi utama
```

## Penjelasan Folder

### 1. `/lib/constants/`
**Purpose**: Menyimpan nilai-nilai konstan yang digunakan di seluruh aplikasi.

**Files**:
- `colors.dart`: Definisi color palette aplikasi
- `text_styles.dart`: Definisi text styles dengan Google Fonts

**Kapan menambahkan file baru**:
- Tambahkan file untuk konstanta baru (misal: `api_endpoints.dart`, `app_strings.dart`)
- Pisahkan berdasarkan kategori untuk maintainability

**Example**:
```dart
// colors.dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFFFF9800);
}
```

### 2. `/lib/models/`
**Purpose**: Menyimpan data models untuk representasi data.

**Files saat ini**:
- `onboarding_model.dart`: Model untuk data onboarding

**Kapan menambahkan file baru**:
- Setiap ada entitas baru (User, Report, Facility, etc.)
- Untuk response dari API
- Untuk local database entities

**Example**:
```dart
// report_model.dart
class Report {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  
  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
  
  // fromJson, toJson methods
}
```

### 3. `/lib/providers/`
**Purpose**: State management menggunakan Provider pattern.

**Files saat ini**:
- `auth_provider.dart`: Authentication state
- `onboarding_provider.dart`: Onboarding state

**Kapan menambahkan file baru**:
- Setiap ada feature baru yang memerlukan state management
- Pisahkan concern (AuthProvider, ReportProvider, ProfileProvider, etc.)

**Best Practice**:
- Satu provider untuk satu concern
- Gunakan `ChangeNotifier` untuk reactive state
- Implement proper error handling

**Example**:
```dart
class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch logic
      _reports = await api.getReports();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 4. `/lib/routes/`
**Purpose**: Konfigurasi routing aplikasi.

**Files**:
- `app_router.dart`: go_router configuration

**Struktur**:
```dart
class AppRouter {
  final AuthProvider authProvider;
  
  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    redirect: (context, state) { ... },
    routes: [ ... ],
  );
}
```

### 5. `/lib/screens/`
**Purpose**: UI screens/pages aplikasi.

**Naming Convention**: `{feature}_screen.dart`

**Files saat ini**:
- `splash_screen.dart`
- `onboarding_screen.dart`
- `login_screen.dart`
- `register_screen.dart`
- `home_screen.dart`

**Best Practice**:
- Satu screen per file
- Gunakan StatefulWidget jika ada local state
- Extract complex widgets ke `/widgets/`

### 6. `/lib/widgets/`
**Purpose**: Reusable widgets yang digunakan di multiple screens.

**Kapan membuat widget di sini**:
- Widget digunakan di 2+ screens
- Widget complex dengan logic tersendiri
- Custom widgets (buttons, cards, dialogs, etc.)

**Example**:
```dart
// custom_button.dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? CircularProgressIndicator()
        : Text(text),
    );
  }
}
```

### 7. `/lib/services/` (Belum ada - akan dibuat)
**Purpose**: Service layer untuk business logic dan API calls.

**Future structure**:
```
lib/services/
├── api/
│   ├── api_client.dart      # HTTP client setup
│   ├── auth_api.dart        # Auth API calls
│   └── report_api.dart      # Report API calls
├── local/
│   ├── local_storage.dart   # SharedPreferences wrapper
│   └── database_service.dart # Local database
└── notification/
    └── notification_service.dart
```

### 8. `/assets/`
**Purpose**: Static assets (images, icons, fonts).

**Structure**:
```
assets/
├── images/
│   ├── logo.png
│   ├── onboarding_1.png
│   ├── onboarding_2.png
│   └── onboarding_3.png
└── icons/
    └── custom_icons/
```

**Best Practice**:
- Gunakan naming convention yang jelas
- Compress images untuk mengurangi size
- Gunakan SVG untuk scalable icons

### 9. `/docs/`
**Purpose**: Dokumentasi project.

**Files**:
- `PROVIDER_GUIDE.md`: Panduan state management
- `ROUTING_GUIDE.md`: Panduan routing
- `FOLDER_STRUCTURE.md`: File ini
- `API_DOCUMENTATION.md`: (Future) API documentation

## Folder yang Akan Ditambahkan

### `/lib/utils/`
Helper functions dan utilities:
```dart
// validators.dart
class Validators {
  static String? validateEmail(String? value) { ... }
  static String? validatePassword(String? value) { ... }
}

// date_formatter.dart
class DateFormatter {
  static String format(DateTime date) { ... }
}
```

### `/lib/services/`
Service layer untuk komunikasi dengan backend dan services:
```dart
// auth_service.dart
class AuthService {
  Future<User> login(String email, String password) { ... }
  Future<void> logout() { ... }
}

// report_service.dart
class ReportService {
  Future<List<Report>> getReports() { ... }
  Future<Report> createReport(Report report) { ... }
}
```

### `/lib/repositories/` (Optional)
Repository pattern untuk abstraksi data source:
```dart
// report_repository.dart
class ReportRepository {
  final ReportApiService _apiService;
  final ReportLocalService _localService;
  
  Future<List<Report>> getReports() async {
    try {
      return await _apiService.getReports();
    } catch (e) {
      return await _localService.getCachedReports();
    }
  }
}
```

## Naming Conventions

### Files
- **Screens**: `{feature}_screen.dart` (contoh: `login_screen.dart`)
- **Widgets**: `{name}_widget.dart` atau `custom_{name}.dart`
- **Models**: `{name}_model.dart` (contoh: `report_model.dart`)
- **Providers**: `{name}_provider.dart` (contoh: `auth_provider.dart`)
- **Services**: `{name}_service.dart` (contoh: `api_service.dart`)

### Classes
- **PascalCase** untuk class names
- **camelCase** untuk methods dan variables
- **SCREAMING_SNAKE_CASE** untuk constants

### Examples
```dart
// ✅ BENAR
class UserProfile { }
class AuthProvider { }
void fetchUserData() { }
const String API_BASE_URL = '...';

// ❌ SALAH
class user_profile { }
class auth_Provider { }
void FetchUserData() { }
const String apiBaseUrl = '...';
```

## Import Organization

Organize imports dalam urutan:
1. Dart core libraries
2. Flutter libraries
3. Third-party packages
4. Project files

```dart
// 1. Dart
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// 4. Project
import 'package:laporin/constants/colors.dart';
import 'package:laporin/providers/auth_provider.dart';
```

## Best Practices Summary

1. **Separation of Concerns**: Pisahkan UI, Business Logic, dan Data
2. **Single Responsibility**: Satu file, satu tanggung jawab
3. **DRY (Don't Repeat Yourself)**: Extract reusable code
4. **Clear Naming**: Gunakan nama yang descriptive
5. **Documentation**: Comment untuk logic yang complex
6. **Consistent Structure**: Follow established patterns

## Resources

- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
