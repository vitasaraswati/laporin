# Panduan Penggunaan State Management dengan Provider

## Overview

Aplikasi LaporJTI menggunakan **Provider** sebagai state management solution. Provider adalah package yang populer dan direkomendasikan oleh Flutter team untuk mengelola state aplikasi.

## Provider yang Ada

### 1. AuthProvider (`lib/providers/auth_provider.dart`)

Provider ini mengelola semua yang berkaitan dengan authentication.

#### Properties:
- `status`: Status authentication (uninitialized, authenticated, unauthenticated)
- `userEmail`: Email user yang sedang login
- `userName`: Nama user yang sedang login
- `isLoading`: Status loading saat proses authentication
- `errorMessage`: Pesan error jika terjadi kesalahan
- `isAuthenticated`: Boolean untuk cek apakah user sudah login

#### Methods:
```dart
// Login dengan email dan password
Future<bool> login(String email, String password)

// Register user baru
Future<bool> register(String name, String email, String password)

// Logout
Future<void> logout()

// Clear error message
void clearError()
```

#### Cara Menggunakan:

**1. Read value (tidak rebuild widget saat berubah):**
```dart
final authProvider = context.read<AuthProvider>();
await authProvider.login(email, password);
```

**2. Watch value (rebuild widget saat berubah):**
```dart
final authProvider = context.watch<AuthProvider>();
Text('Welcome, ${authProvider.userName}');
```

**3. Menggunakan Consumer (recommended untuk partial rebuild):**
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text('Email: ${authProvider.userEmail}');
  },
)
```

### 2. OnboardingProvider (`lib/providers/onboarding_provider.dart`)

Provider ini mengelola state onboarding screen.

#### Properties:
- `currentPage`: Halaman onboarding yang sedang aktif
- `isLastPage`: Boolean untuk cek apakah ini halaman terakhir

#### Methods:
```dart
// Set halaman aktif
void setCurrentPage(int page, int totalPages)

// Complete onboarding (simpan ke SharedPreferences)
Future<void> completeOnboarding()

// Check apakah onboarding sudah complete
static Future<bool> isOnboardingComplete()

// Reset state
void reset()
```

## Best Practices

### 1. Gunakan read() untuk Actions
Jangan gunakan `watch()` atau `Consumer` untuk trigger actions, gunakan `read()`:

```dart
// ✅ BENAR
onPressed: () {
  context.read<AuthProvider>().logout();
}

// ❌ SALAH (akan rebuild setiap kali state berubah)
onPressed: () {
  context.watch<AuthProvider>().logout();
}
```

### 2. Gunakan Consumer untuk Partial Rebuild
Gunakan `Consumer` untuk rebuild hanya widget yang perlu update:

```dart
// ✅ BENAR - Hanya button yang rebuild
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return ElevatedButton(
      onPressed: authProvider.isLoading ? null : _handleLogin,
      child: authProvider.isLoading
          ? CircularProgressIndicator()
          : Text('Login'),
    );
  },
)

// ❌ KURANG OPTIMAL - Seluruh body rebuild
Widget build(BuildContext context) {
  final authProvider = context.watch<AuthProvider>();
  return Scaffold(
    body: ElevatedButton(
      onPressed: authProvider.isLoading ? null : _handleLogin,
      child: authProvider.isLoading
          ? CircularProgressIndicator()
          : Text('Login'),
    ),
  );
}
```

### 3. Simpan State yang Persistent
Untuk data yang perlu disimpan saat app ditutup, gunakan SharedPreferences:

```dart
// Simpan data
final prefs = await SharedPreferences.getInstance();
await prefs.setString('user_email', email);

// Baca data
final email = prefs.getString('user_email');
```

## Menambahkan Provider Baru

### Langkah-langkah:

1. **Buat file provider baru** di `lib/providers/`:
```dart
import 'package:flutter/foundation.dart';

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];
  
  List<Report> get reports => _reports;
  
  void addReport(Report report) {
    _reports.add(report);
    notifyListeners(); // Notify semua listener
  }
}
```

2. **Daftarkan di main.dart**:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider()), // Tambahkan ini
  ],
  child: MaterialApp.router(...),
)
```

3. **Gunakan di widget**:
```dart
// Read
context.read<ReportProvider>().addReport(newReport);

// Watch
final reports = context.watch<ReportProvider>().reports;

// Consumer
Consumer<ReportProvider>(
  builder: (context, reportProvider, child) {
    return ListView.builder(
      itemCount: reportProvider.reports.length,
      itemBuilder: (context, index) {
        return ReportCard(report: reportProvider.reports[index]);
      },
    );
  },
)
```

## Error Handling

### 1. Handling Async Operations:
```dart
try {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();
  
  // Async operation
  await someAsyncOperation();
  
  _isLoading = false;
  notifyListeners();
} catch (e) {
  _errorMessage = 'Error: $e';
  _isLoading = false;
  notifyListeners();
}
```

### 2. Showing Error Messages:
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Listen for errors
    if (authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
        authProvider.clearError();
      });
    }
    
    return YourWidget();
  },
)
```

## Tips & Tricks

1. **Jangan panggil notifyListeners() terlalu sering** - bisa menyebabkan performance issue
2. **Gunakan selector untuk optimize rebuild** - hanya rebuild saat value tertentu berubah
3. **Dispose controller dengan benar** - hindari memory leak
4. **Testing** - Provider mudah di-test dengan MockProvider

## Resources

- [Provider Documentation](https://pub.dev/packages/provider)
- [Flutter State Management Guide](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple)
