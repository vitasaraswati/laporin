# Panduan Routing dengan go_router

## Overview

Aplikasi LaporJTI menggunakan **go_router** untuk navigasi. go_router adalah package routing yang powerful dengan dukungan untuk deep linking, redirect, dan error handling.

## Struktur Routing

### Routes yang Tersedia:

| Path | Name | Screen | Protected |
|------|------|--------|-----------|
| `/` | splash | SplashScreen | No |
| `/onboarding` | onboarding | OnboardingScreen | No |
| `/login` | login | LoginScreen | No |
| `/register` | register | RegisterScreen | No |
| `/home` | home | HomeScreen | Yes |

### Protected Routes

Protected routes memerlukan authentication. Jika user belum login, akan di-redirect ke `/login`.

## Cara Navigasi

### 1. Push (Menambahkan screen ke stack)
```dart
// Navigasi ke register dari login
context.push('/register');
```

### 2. Go (Replace current route)
```dart
// Navigasi ke home setelah login
context.go('/home');
```

### 3. Pop (Kembali ke screen sebelumnya)
```dart
// Kembali ke screen sebelumnya
context.pop();

// Kembali dengan return value
context.pop(result);
```

### 4. Named Routes
```dart
// Menggunakan named routes
context.goNamed('home');
context.pushNamed('register');
```

## Redirect Logic

Router memiliki redirect logic untuk menangani authentication dan onboarding:

```dart
redirect: (BuildContext context, GoRouterState state) async {
  final isAuthenticated = authProvider.isAuthenticated;
  final isOnboardingComplete = await OnboardingProvider.isOnboardingComplete();
  
  // User authenticated -> redirect to home
  if (isAuthenticated && !state.matchedLocation.contains('/home')) {
    return '/home';
  }
  
  // Onboarding not complete -> redirect to onboarding
  if (!isOnboardingComplete && !state.matchedLocation.contains('/onboarding')) {
    return '/onboarding';
  }
  
  // Accessing protected route without auth -> redirect to login
  if (!isAuthenticated && state.matchedLocation.contains('/home')) {
    return '/login';
  }
  
  return null; // No redirect
}
```

## Authentication Flow

```
Splash Screen (3s)
    ↓
Onboarding Complete? ──No──→ Onboarding Screen ──→ Login Screen
    ↓ Yes
    ↓
User Authenticated? ──No──→ Login Screen
    ↓ Yes                      ↓ Login Success
    ↓                          ↓
Home Screen ←─────────────────┘
```

## Error Handling

Router memiliki error builder untuk menangani route yang tidak ditemukan:

```dart
errorBuilder: (context, state) => Scaffold(
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64),
        Text('Halaman tidak ditemukan'),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: Text('Kembali ke Login'),
        ),
      ],
    ),
  ),
),
```

## Menambahkan Route Baru

### 1. Definisikan route di app_router.dart:

```dart
GoRoute(
  path: '/report',
  name: 'report',
  builder: (context, state) => const ReportScreen(),
),
```

### 2. Dengan parameter:

```dart
GoRoute(
  path: '/report/:id',
  name: 'reportDetail',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ReportDetailScreen(id: id);
  },
),
```

### 3. Dengan query parameters:

```dart
// Navigasi
context.push('/report?status=pending&sort=date');

// Di builder
builder: (context, state) {
  final status = state.uri.queryParameters['status'];
  final sort = state.uri.queryParameters['sort'];
  return ReportScreen(status: status, sort: sort);
},
```

### 4. Nested routes:

```dart
GoRoute(
  path: '/home',
  name: 'home',
  builder: (context, state) => const HomeScreen(),
  routes: [
    GoRoute(
      path: 'profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: 'settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
),

// Navigasi ke nested route
context.go('/home/profile');
```

## Passing Data Between Screens

### 1. Via Path Parameters:
```dart
// Definisi route
GoRoute(
  path: '/report/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ReportDetailScreen(id: id);
  },
),

// Navigasi
context.push('/report/123');
```

### 2. Via Extra:
```dart
// Definisi route
GoRoute(
  path: '/report-detail',
  builder: (context, state) {
    final report = state.extra as Report;
    return ReportDetailScreen(report: report);
  },
),

// Navigasi
context.push('/report-detail', extra: reportObject);
```

### 3. Via Query Parameters:
```dart
// Navigasi
context.push('/report?id=123&status=pending');

// Di screen
final id = state.uri.queryParameters['id'];
final status = state.uri.queryParameters['status'];
```

## Deep Linking

go_router mendukung deep linking secara otomatis:

```
// Format: scheme://host/path
myapp://laporjti.com/report/123

// Akan membuka ReportDetailScreen dengan id=123
```

### Setup Deep Linking:

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="myapp" android:host="laporjti.com" />
</intent-filter>
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

## Best Practices

1. **Gunakan named routes** untuk route yang sering digunakan
2. **Gunakan go() untuk replace** dan **push() untuk stack**
3. **Validate parameters** sebelum digunakan
4. **Handle loading states** saat melakukan redirect
5. **Use type-safe navigation** dengan extension methods

### Example Extension:
```dart
extension AppRouterExtension on BuildContext {
  void goToHome() => go('/home');
  void goToLogin() => go('/login');
  void goToReportDetail(String id) => push('/report/$id');
}

// Usage
context.goToHome();
context.goToReportDetail('123');
```

## Debugging

Enable debug log:
```dart
GoRouter(
  debugLogDiagnostics: true, // Enable logging
  ...
)
```

## Resources

- [go_router Documentation](https://pub.dev/packages/go_router)
- [go_router Examples](https://github.com/flutter/packages/tree/main/packages/go_router/example)
