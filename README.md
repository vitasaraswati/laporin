# LaporJTI - Aplikasi Pelaporan Fasilitas Kampus

Aplikasi mobile untuk melaporkan kerusakan fasilitas di kampus JTI.

## 🚀 Fitur yang Telah Dibuat

### ✅ Fase 1 (Selesai)
- **Splash Screen**: Animasi splash screen dengan logo LaporJTI
- **Onboarding Screen**: 3 halaman onboarding dengan smooth page indicator
- **Login Screen**: Form login dengan validasi email dan password
- **Register Screen**: Form registrasi dengan validasi lengkap
- **Home Screen**: Halaman utama dengan menu grid (placeholder)
- **State Management**: Menggunakan Provider untuk mengelola state
- **Routing**: Navigasi menggunakan go_router dengan redirect logic

## 📁 Struktur Project

```
lib/
├── constants/
│   ├── colors.dart           # Definisi warna aplikasi
│   └── text_styles.dart      # Definisi text styles dengan Google Fonts
├── models/
│   └── onboarding_model.dart # Model untuk data onboarding
├── providers/
│   ├── auth_provider.dart    # Provider untuk authentication
│   └── onboarding_provider.dart # Provider untuk onboarding
├── routes/
│   └── app_router.dart       # Konfigurasi routing dengan go_router
├── screens/
│   ├── splash_screen.dart    # Splash screen dengan animasi
│   ├── onboarding_screen.dart # Onboarding screen
│   ├── login_screen.dart     # Login screen
│   ├── register_screen.dart  # Register screen
│   └── home_screen.dart      # Home screen
└── main.dart                 # Entry point aplikasi
```

## 🎨 Design System

### Warna
- **Primary**: #2196F3 (Blue)
- **Secondary**: #FF9800 (Orange)
- **Success**: #4CAF50
- **Error**: #F44336
- **Background**: #F5F5F5

### Typography
Menggunakan Google Fonts Poppins untuk konsistensi typography.

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2              # State management
  go_router: ^14.6.2            # Routing
  shared_preferences: ^2.3.3    # Local storage
  smooth_page_indicator: ^1.2.0 # Onboarding indicators
  google_fonts: ^6.2.1          # Typography
```

## 🔐 Authentication Flow

1. **Splash Screen** → Ditampilkan selama 3 detik
2. **Onboarding Screen** → Hanya muncul sekali (first time user)
3. **Login Screen** → Default entry point setelah onboarding
4. **Register Screen** → Accessible dari login screen
5. **Home Screen** → Accessible setelah login/register berhasil

### State Management dengan Provider

- **AuthProvider**: Mengelola authentication state (login, register, logout)
- **OnboardingProvider**: Mengelola onboarding state dan progress

## 🚦 Routing

Aplikasi menggunakan **go_router** dengan fitur:
- Declarative routing
- Deep linking support
- Redirect logic untuk authentication
- Error handling

### Routes:
- `/` - Splash Screen
- `/onboarding` - Onboarding Screen
- `/login` - Login Screen
- `/register` - Register Screen
- `/home` - Home Screen (Protected)

## 💾 Local Storage

Menggunakan **SharedPreferences** untuk:
- Menyimpan status onboarding
- Menyimpan data user (email, name)
- Menyimpan status authentication

## 🔧 Cara Menjalankan

1. Clone repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run aplikasi:
   ```bash
   flutter run
   ```

## 📝 Catatan untuk Development

### Login Credentials (Development)
Saat ini menggunakan validasi mock:
- Email: Format email yang valid
- Password: Minimal 6 karakter

### TODO: Fitur Selanjutnya
- [ ] Integrasi dengan Backend API
- [ ] Implementasi form laporan fasilitas
- [ ] Upload gambar untuk laporan
- [ ] List dan detail laporan
- [ ] Notifikasi real-time
- [ ] Profile management
- [ ] History laporan
- [ ] Admin dashboard

## 🎯 Best Practices yang Diterapkan

1. **Clean Architecture**: Pemisahan concerns (UI, Business Logic, Data)
2. **State Management**: Menggunakan Provider pattern
3. **Reusable Components**: Constants untuk colors dan text styles
4. **Form Validation**: Input validation untuk semua forms
5. **Error Handling**: Proper error messages dan user feedback
6. **Navigation**: Proper routing dengan authentication guards
7. **UI/UX**: Smooth animations dan transitions

## 👨‍💻 Developer

Developed with ❤️ for JTI Campus

---

**Version**: 1.0.0
**Last Updated**: November 12, 2025
