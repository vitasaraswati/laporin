# 📝 Important Notes - LaporJTI Development

## Current Implementation Notes

### 1. Mock Authentication
⚠️ **Saat ini menggunakan MOCK authentication**

```dart
// lib/providers/auth_provider.dart
// Validasi hanya format email dan panjang password
// BELUM tersambung ke backend API
```

**Yang perlu diubah nanti**:
- Replace mock validation dengan API call
- Implement token storage
- Add token refresh logic
- Handle API errors properly

### 2. Local Storage
📦 Menggunakan **SharedPreferences** untuk:
- Onboarding completion status
- User email
- User name
- Authentication status

**Catatan**:
- Data tidak terenkripsi
- Untuk production, gunakan `flutter_secure_storage` untuk data sensitif
- Token harus disimpan dengan aman

### 3. Onboarding
✨ Onboarding hanya muncul **sekali** (first time user)

**Reset onboarding** untuk testing:
```dart
// Temporary code untuk reset
final prefs = await SharedPreferences.getInstance();
await prefs.remove('onboarding_complete');
```

Atau uninstall & reinstall app.

### 4. Asset Images
🖼️ Saat ini menggunakan **emoji placeholder** untuk onboarding images

**File**: `lib/models/onboarding_model.dart`
```dart
image: '📱', // Ganti dengan path gambar
```

**Cara mengganti**:
1. Tambahkan gambar ke `assets/images/`
2. Update path:
```dart
image: 'assets/images/onboarding_1.png',
```
3. Gunakan di widget:
```dart
Image.asset(data.image)
```

### 5. Form Validation Rules

**Email**:
- Required
- Format email valid (regex)

**Password**:
- Required
- Minimal 6 karakter
- Tidak ada requirement khusus (bisa ditambahkan)

**Name**:
- Required
- Minimal 3 karakter

### 6. Navigation Behavior

**Authentication Guards**:
- `/home` → Requires login
- `/` (splash) → Always accessible
- `/onboarding` → Only first time
- `/login`, `/register` → Accessible without login

**Redirect Logic**:
```
Authenticated → Home
Not Authenticated + Onboarding Complete → Login
Not Authenticated + Onboarding Not Complete → Onboarding
```

### 7. State Management Gotchas

⚠️ **Common Mistakes**:

```dart
// ❌ WRONG - Will rebuild on every state change
Widget build(BuildContext context) {
  final authProvider = context.watch<AuthProvider>();
  return ElevatedButton(
    onPressed: () => authProvider.logout(),
  );
}

// ✅ CORRECT - Only rebuild when needed
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<AuthProvider>().logout(),
  );
}
```

### 8. Error Handling

**Current Implementation**:
- Form validation errors
- Provider error messages
- SnackBar notifications

**TODO**:
- API error handling
- Network error handling
- Timeout handling
- Retry logic

### 9. Loading States

**Implemented**:
- Login/Register buttons
- Provider loading state

**TODO**:
- Global loading overlay
- Shimmer loading for lists
- Pull to refresh indicators

### 10. Test Data

**Login** (mock):
```
Email: test@example.com (any valid email)
Password: password123 (min 6 chars)
```

**Register** (mock):
```
Name: John Doe (min 3 chars)
Email: john@example.com (valid email)
Password: password123 (min 6 chars)
Confirm: password123 (must match)
Terms: Must be checked
```

---

## Known Issues & Limitations

### Current Limitations:

1. **No Backend Connection**
   - All authentication is mocked
   - Data not persisted to server
   - No real user accounts

2. **No Image Assets**
   - Using emoji placeholders
   - Logo is icon-based
   - Need actual images for production

3. **No Network Error Handling**
   - No offline mode
   - No retry logic
   - No connection status check

4. **Limited Validation**
   - Basic email/password validation
   - No password strength indicator
   - No email verification

5. **No Security Features**
   - No encryption
   - No secure storage
   - No certificate pinning

### Future Improvements:

1. **Security**
   - Implement flutter_secure_storage
   - Add certificate pinning
   - Encrypt sensitive data
   - Add biometric authentication

2. **UX**
   - Add password strength indicator
   - Add email verification flow
   - Add forgot password
   - Add social login options

3. **Performance**
   - Add image caching
   - Implement lazy loading
   - Optimize build methods
   - Add app profiling

4. **Features**
   - Dark mode support
   - Multi-language support
   - Accessibility features
   - Offline mode

---

## Development Tips

### 1. Hot Reload vs Hot Restart

**Hot Reload** (`r` in terminal):
- Quick
- Preserves state
- For UI changes

**Hot Restart** (`R` in terminal):
- Slower
- Resets state
- For provider/logic changes

### 2. Debugging

**Print Debugging**:
```dart
print('Current auth status: ${authProvider.status}');
```

**Debug Console**:
- Run app dengan `flutter run -v` untuk verbose logging

**Flutter DevTools**:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 3. Testing Providers

```dart
// Create test provider
final authProvider = AuthProvider();

// Test login
await authProvider.login('test@mail.com', 'password123');

// Check state
expect(authProvider.isAuthenticated, true);
```

### 4. Common Errors & Solutions

**Error: "Waiting for another flutter command..."**
```bash
# Kill all dart processes
taskkill /F /IM dart.exe /T
```

**Error: "Gradle build failed"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Error: Widget rebuild loop**
```dart
// Don't use watch() for actions
// Use read() instead
context.read<Provider>().action();
```

### 5. Performance Tips

```dart
// ✅ Use const constructors
const Text('Hello');

// ✅ Extract widgets
class MyButton extends StatelessWidget {
  // ...
}

// ✅ Use keys for lists
ListView.builder(
  key: ValueKey('my-list'),
  // ...
)

// ❌ Avoid
ListView(
  children: items.map((item) => 
    Text(item) // Creates new widget each rebuild
  ).toList(),
)
```

---

## Code Quality Standards

### Required Before Commit:

1. **No Lint Errors**
   ```bash
   flutter analyze
   ```

2. **Formatted Code**
   ```bash
   flutter format lib/
   ```

3. **No Debug Code**
   - Remove all `print()` statements
   - Remove commented code
   - Remove `debugPrint()` in production

4. **Proper Comments**
   - Comment complex logic
   - Add TODO for future work
   - Document public APIs

### Code Review Checklist:

- [ ] No hardcoded strings (use constants)
- [ ] No magic numbers
- [ ] Proper error handling
- [ ] Loading states implemented
- [ ] Form validation
- [ ] Responsive design
- [ ] Accessibility labels

---

## Environment Variables (Future)

**Setup untuk production**:

```dart
// lib/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.laporjti.com',
  );
  
  static const String apiKey = String.fromEnvironment('API_KEY');
}
```

**Run dengan env**:
```bash
flutter run --dart-define=API_BASE_URL=https://api.dev.laporjti.com
```

---

## Version Control

### Branch Strategy:
```
main (production)
  ├── develop (development)
  │     ├── feature/report-form
  │     ├── feature/notifications
  │     └── fix/login-bug
```

### Commit Message Format:
```
feat: Add report creation form
fix: Fix login error handling
docs: Update README
style: Format code
refactor: Improve provider structure
test: Add auth provider tests
```

---

## Resources & References

### Official Documentation:
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design](https://m3.material.io/)

### Packages Used:
- [Provider](https://pub.dev/packages/provider)
- [go_router](https://pub.dev/packages/go_router)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [google_fonts](https://pub.dev/packages/google_fonts)

### Recommended Packages (Future):
- [dio](https://pub.dev/packages/dio) - HTTP client
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Secure storage
- [image_picker](https://pub.dev/packages/image_picker) - Image selection
- [firebase_messaging](https://pub.dev/packages/firebase_messaging) - Push notifications
- [cached_network_image](https://pub.dev/packages/cached_network_image) - Image caching

---

## Contact & Support

**Project Lead**: [Your Name]
**Repository**: [GitHub URL]
**Documentation**: See `docs/` folder

---

**Last Updated**: November 12, 2025
**Current Phase**: Phase 1 Complete ✅
**Next Phase**: Backend Integration 🚀
