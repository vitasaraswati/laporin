# 📘 LaporJTI Development Guide

Panduan lengkap untuk developer yang akan melanjutkan development aplikasi LaporJTI.

---

## 📂 Project Structure

```
laporin/
├── lib/
│   ├── constants/          # App constants (colors, text styles)
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   │
│   ├── models/            # Data models
│   │   ├── user_model.dart
│   │   ├── report_model.dart
│   │   ├── location_model.dart
│   │   ├── media_model.dart
│   │   └── enums.dart
│   │
│   ├── providers/         # State management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── onboarding_provider.dart
│   │   └── report_provider.dart
│   │
│   ├── routes/           # App routing (go_router)
│   │   └── app_router.dart
│   │
│   ├── screens/          # UI screens
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── create_report_screen.dart
│   │   ├── report_list_screen.dart
│   │   ├── report_detail_screen.dart
│   │   └── admin_dashboard_screen.dart
│   │
│   ├── services/         # Business logic & API calls
│   │   ├── firebase_auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── firebase_storage_service.dart
│   │
│   ├── widgets/          # Reusable widgets
│   │   └── profile_drawer.dart
│   │
│   ├── firebase_options.dart  # Firebase configuration
│   └── main.dart              # App entry point
│
├── android/              # Android native code
├── ios/                  # iOS native code
├── assets/              # Images, icons, etc
├── docs/                # Additional documentation
└── test/                # Unit & widget tests
```

---

## 🎨 Architecture Overview

### **State Management: Provider**

```dart
// Providers available:
- AuthProvider         → Authentication state
- OnboardingProvider   → Onboarding flow state
- ReportProvider       → Reports management state
```

### **Routing: go_router**

```dart
// Routes defined in app_router.dart:
/                  → SplashScreen
/onboarding        → OnboardingScreen
/login             → LoginScreen
/register          → RegisterScreen
/home              → HomeScreen (protected)
```

### **Services Layer**

```dart
FirebaseAuthService      → Firebase Authentication
FirestoreService         → Cloud Firestore operations
FirebaseStorageService   → File upload/download
```

---

## 🔐 Authentication Flow

### **Mock Mode (Default)**

```dart
// AuthProvider automatically uses mock auth
// Mock credentials available in auth_provider.dart:
admin@laporin.com / admin123
mahasiswa@student.polinema.ac.id / mahasiswa123
dosen@polinema.ac.id / dosen123
```

### **Firebase Mode**

```dart
// Enable Firebase authentication:
authProvider.setUseFirebase(true);

// Will use real Firebase Auth + Firestore
```

### **Toggle Between Modes**

```dart
// In AuthProvider:
bool get useFirebase => _useFirebase;
void setUseFirebase(bool value);

// Usage:
final authProvider = context.read<AuthProvider>();
authProvider.setUseFirebase(true);  // Enable Firebase
authProvider.setUseFirebase(false); // Use mock
```

---

## 👥 User Roles

```dart
enum UserRole {
  admin,      // Full access, can manage all reports
  mahasiswa,  // Can create & view reports
  dosen,      // Can view & comment on reports
}
```

### **Role-Based Access**

```dart
// In AuthProvider:
bool get isAdmin => _currentUser?.role == UserRole.admin;
bool get isMahasiswa => _currentUser?.role == UserRole.mahasiswa;
bool get isDosen => _currentUser?.role == UserRole.dosen;

bool canManageReports() => isAdmin;
bool canCreateReports() => _currentUser != null;
```

---

## 📝 Reports Management

### **Report Model**

```dart
class Report {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportStatus status;
  final Location location;
  final List<String> images;
  final DateTime createdAt;
}
```

### **Report Status Flow**

```
pending → in_progress → resolved
   ↓
rejected
```

### **Create Report**

```dart
// Using FirestoreService:
final firestoreService = FirestoreService();
final reportId = await firestoreService.createReport(report);
```

### **Update Report Status (Admin)**

```dart
await firestoreService.updateReportStatus(
  reportId,
  ReportStatus.inProgress,
);
```

---

## 🖼️ Image Upload

### **Upload Single Image**

```dart
final storageService = FirebaseStorageService();

final imageUrl = await storageService.uploadImage(
  imageFile: File('path/to/image'),
  userId: currentUser.id,
  folder: 'reports',
);
```

### **Upload Multiple Images**

```dart
final urls = await storageService.uploadMultipleImages(
  imageFiles: [image1, image2, image3],
  userId: currentUser.id,
  folder: 'reports',
  onProgress: (current, total) {
    print('Uploading $current of $total');
  },
);
```

---

## 🎨 Theming & Styling

### **Colors** (`constants/colors.dart`)

```dart
AppColors.primary       // #2196F3 (Blue)
AppColors.secondary     // #FF9800 (Orange)
AppColors.success       // #4CAF50 (Green)
AppColors.error         // #F44336 (Red)
AppColors.warning       // #FFC107 (Amber)
AppColors.info          // #00BCD4 (Cyan)
```

### **Text Styles** (`constants/text_styles.dart`)

```dart
AppTextStyles.h1        // Heading 1
AppTextStyles.h2        // Heading 2
AppTextStyles.h3        // Heading 3
AppTextStyles.bodyLarge // Body large
AppTextStyles.bodyMedium // Body medium
AppTextStyles.bodySmall  // Body small
AppTextStyles.button     // Button text
```

### **Using in UI**

```dart
Text(
  'Hello World',
  style: AppTextStyles.h2.copyWith(
    color: AppColors.primary,
  ),
)
```

---

## 🔄 State Management Patterns

### **Using AuthProvider**

```dart
// In widget:
final authProvider = context.watch<AuthProvider>();

if (authProvider.isLoading) {
  return CircularProgressIndicator();
}

if (authProvider.isAuthenticated) {
  return Text('Welcome ${authProvider.userName}');
}
```

### **Using ReportProvider**

```dart
final reportProvider = context.watch<ReportProvider>();

ListView.builder(
  itemCount: reportProvider.reports.length,
  itemBuilder: (context, index) {
    final report = reportProvider.reports[index];
    return ReportCard(report: report);
  },
)
```

---

## 🧪 Testing

### **Run Tests**

```bash
flutter test
```

### **Run Tests with Coverage**

```bash
flutter test --coverage
```

### **Test Structure**

```
test/
├── unit/              # Unit tests
│   ├── models/
│   ├── providers/
│   └── services/
├── widget/           # Widget tests
│   └── screens/
└── integration/      # Integration tests
```

---

## 🚀 Building & Running

### **Development**

```bash
# Run in debug mode
flutter run

# Run with specific device
flutter run -d <device_id>

# Hot reload: press 'r'
# Hot restart: press 'R'
```

### **Build APK (Android)**

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by ABI (smaller size)
flutter build apk --split-per-abi
```

### **Build iOS**

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

---

## 🐛 Debugging

### **Enable Debug Mode**

```dart
// In app_router.dart:
debugLogDiagnostics: true,  // Enable go_router logs
```

### **Check Firebase Connection**

```dart
// In main.dart, will print:
✅ Firebase initialized successfully
// OR
⚠️ Firebase initialization failed
```

### **Useful Commands**

```bash
# Check Flutter doctor
flutter doctor -v

# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Format code
flutter format .
```

---

## 📦 Dependencies Management

### **Update Dependencies**

```bash
# Update all dependencies
flutter pub upgrade

# Update specific package
flutter pub upgrade <package_name>
```

### **Add New Dependency**

```bash
# Add to pubspec.yaml, then:
flutter pub get
```

---

## 🔒 Security Best Practices

### **1. Never Commit Sensitive Data**

```gitignore
# Already in .gitignore:
google-services.json
GoogleService-Info.plist
firebase_options.dart (if contains secrets)
.env
```

### **2. Firestore Security Rules**

See `FIREBASE_SETUP.md` for production-ready security rules.

### **3. Input Validation**

Always validate user inputs:
```dart
if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
  return 'Email tidak valid';
}
```

---

## 🎯 Common Tasks

### **Add New Screen**

1. Create file in `lib/screens/`
2. Add route in `app_router.dart`
3. Navigate using `context.push('/route')`

### **Add New Provider**

1. Create file in `lib/providers/`
2. Extend `ChangeNotifier`
3. Add to `MultiProvider` in `main.dart`

### **Add New Service**

1. Create file in `lib/services/`
2. Implement service methods
3. Use in Provider or Screen

### **Add New Model**

1. Create file in `lib/models/`
2. Add `fromJson` and `toJson` methods
3. Add `copyWith` for immutability

---

## 📱 Platform-Specific Notes

### **Android**

- Min SDK: 21 (Android 5.0)
- Target SDK: Latest
- Multidex enabled

### **iOS**

- iOS 12.0+
- CocoaPods required

---

## 🔄 Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes, then:
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature

# Create Pull Request on GitHub
```

### **Commit Message Convention**

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update dependencies
```

---

## 📞 Getting Help

- Check existing documentation in `/docs`
- Review code comments
- Check Firebase Console for backend issues
- Flutter documentation: [flutter.dev](https://flutter.dev)
- FlutterFire docs: [firebase.flutter.dev](https://firebase.flutter.dev)

---

**Happy Coding! 🚀**
