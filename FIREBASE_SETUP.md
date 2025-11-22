# 🔥 Firebase Setup Guide - LaporJTI

Panduan lengkap untuk mengintegrasikan Firebase dengan aplikasi LaporJTI.

---

## 📋 Prerequisites

1. **Node.js & npm** - Untuk Firebase CLI
2. **Firebase Account** - Buat di [firebase.google.com](https://firebase.google.com)
3. **Flutter SDK** - Sudah terinstall

---

## 🚀 Step-by-Step Setup

### **Step 1: Install Firebase CLI**

```bash
npm install -g firebase-tools
```

Verify installation:
```bash
firebase --version
```

### **Step 2: Login ke Firebase**

```bash
firebase login
```

### **Step 3: Install FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
```

Pastikan path sudah ditambahkan ke environment:
```bash
# Windows
# Add to PATH: %USERPROFILE%\AppData\Local\Pub\Cache\bin

# macOS/Linux
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### **Step 4: Buat Firebase Project**

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Klik **"Add project"**
3. Nama project: **laporjti** (atau sesuai keinginan)
4. Enable/Disable Google Analytics (opsional)
5. Create project

### **Step 5: Configure FlutterFire**

Di root directory project, jalankan:

```bash
flutterfire configure
```

Pilih:
- Select Firebase project yang sudah dibuat
- Select platforms: **android**, **ios** (dan platform lain jika perlu)
- Confirm

Command ini akan:
✅ Generate file `firebase_options.dart`
✅ Register aplikasi di Firebase Console
✅ Download konfigurasi files

### **Step 6: Setup Firebase Authentication**

1. Buka Firebase Console → **Authentication**
2. Klik **"Get started"**
3. Enable **Email/Password** sign-in method
4. Save

### **Step 7: Setup Cloud Firestore**

1. Buka Firebase Console → **Firestore Database**
2. Klik **"Create database"**
3. Pilih **"Start in test mode"** (untuk development)
4. Pilih location: **asia-southeast1** (Singapore) atau terdekat
5. Enable

### **Step 8: Setup Firebase Storage**

1. Buka Firebase Console → **Storage**
2. Klik **"Get started"**
3. Pilih **"Start in test mode"**
4. Confirm location
5. Done

### **Step 9: Setup Security Rules**

#### **Firestore Rules** (Development)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Reports collection
    match /reports/{reportId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (request.auth.uid == resource.data.user_id ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow delete: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

#### **Storage Rules** (Development)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /reports/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **Step 10: Update main.dart**

File sudah diupdate, pastikan import `firebase_options.dart`:

```dart
import 'package:laporin/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

### **Step 11: Android Configuration**

Edit `android/app/build.gradle`:

```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 21  // Update from 16 to 21
        multiDexEnabled true
    }
}

dependencies {
    ...
    implementation 'com.android.support:multidex:1.0.3'
}
```

### **Step 12: Enable Firebase in App**

Untuk mengaktifkan Firebase authentication (default: mock mode):

```dart
// In your login/register screen or settings
final authProvider = context.read<AuthProvider>();
authProvider.setUseFirebase(true); // Enable Firebase
```

---

## 📦 Dependencies Installed

Sudah ditambahkan di `pubspec.yaml`:

```yaml
firebase_core: ^3.8.0
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.6
firebase_messaging: ^15.1.5
```

---

## 🧪 Testing

### **Test Mock Auth (Default)**
```dart
// Login with mock credentials
Email: admin@laporin.com
Password: admin123

Email: mahasiswa@student.polinema.ac.id
Password: mahasiswa123

Email: dosen@polinema.ac.id
Password: dosen123
```

### **Test Firebase Auth**
1. Enable Firebase: `authProvider.setUseFirebase(true)`
2. Register new user via app
3. Check Firebase Console → Authentication → Users

---

## 🗂️ Firestore Data Structure

```
laporjti/
├── users/
│   └── {userId}/
│       ├── id: string
│       ├── name: string
│       ├── email: string
│       ├── role: string (admin|mahasiswa|dosen)
│       ├── nim: string? (for mahasiswa)
│       ├── nip: string? (for dosen)
│       ├── phone: string?
│       ├── avatar_url: string?
│       └── created_at: timestamp
│
└── reports/
    └── {reportId}/
        ├── id: string
        ├── user_id: string
        ├── title: string
        ├── description: string
        ├── category: string
        ├── status: string (pending|in_progress|resolved|rejected)
        ├── location: map
        │   ├── latitude: number
        │   ├── longitude: number
        │   └── address: string
        ├── images: array<string>
        ├── created_at: timestamp
        └── updated_at: timestamp
```

---

## 🔧 Troubleshooting

### **Error: Firebase not initialized**
- Pastikan `flutterfire configure` sudah dijalankan
- Check file `firebase_options.dart` exists
- Verify `Firebase.initializeApp()` dipanggil di `main()`

### **Error: minSdkVersion too low**
- Update `android/app/build.gradle`
- Set `minSdkVersion 21`

### **Error: Multidex**
- Enable `multiDexEnabled true` di build.gradle
- Add multidex dependency

### **Error: Platform not supported**
- Run `flutterfire configure` lagi
- Pilih platform yang dibutuhkan

---

## 📱 Platform-Specific Files

Setelah `flutterfire configure`, file berikut akan digenerate:

### **Android**
- `android/app/google-services.json` ✅

### **iOS**
- `ios/Runner/GoogleService-Info.plist` ✅

### **Web**
- Konfigurasi di `web/index.html` ✅

---

## 🎯 Next Steps

1. ✅ Setup Firebase project
2. ✅ Configure FlutterFire
3. ✅ Enable Authentication
4. ✅ Setup Firestore
5. ✅ Setup Storage
6. ✅ Configure Security Rules
7. 🔲 Test di real device
8. 🔲 Deploy ke production
9. 🔲 Setup Firebase Messaging (notifications)
10. 🔲 Setup Firebase Analytics

---

## 📚 Resources

- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Firebase Storage](https://firebase.google.com/docs/storage)

---

## 🆘 Support

Jika ada masalah:
1. Check error di console
2. Verify Firebase configuration
3. Check Firebase Console → Usage & billing
4. Pastikan internet connection stable

**Happy Coding! 🚀**
