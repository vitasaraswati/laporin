# ⚡ Quick Firebase Start Guide

Panduan super cepat untuk memulai Firebase di LaporJTI.

---

## 🎯 Pilihan: Dengan atau Tanpa Firebase?

### **Option 1: Tanpa Firebase (Mock Mode) - SUDAH JALAN! ✅**

Aplikasi sudah bisa jalan langsung dengan mock authentication. Tidak perlu setup Firebase.

```bash
# Langsung run:
flutter pub get
flutter run
```

**Mock credentials:**
- Admin: `admin@laporin.com` / `admin123`
- Mahasiswa: `mahasiswa@student.polinema.ac.id` / `mahasiswa123`
- Dosen: `dosen@polinema.ac.id` / `dosen123`

---

### **Option 2: Dengan Firebase (Real Backend)**

Ikuti langkah berikut untuk mengaktifkan Firebase.

---

## 🚀 5-Minute Firebase Setup

### **1. Install Tools**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

### **2. Create Firebase Project**

1. Buka [console.firebase.google.com](https://console.firebase.google.com)
2. **Create a project** → Nama: `laporjti`
3. Disable Google Analytics (optional)
4. Create project

### **3. Run FlutterFire Configure**

```bash
# Di root folder project:
cd D:\COOLYEAH\PEM MOBILE\PBL\laporin

# Configure Firebase
flutterfire configure
```

**Pilih:**
- Project: `laporjti` (yang baru dibuat)
- Platforms: `android`, `ios` (pilih sesuai kebutuhan)
- Confirm

✅ Akan auto-generate `firebase_options.dart` dan download config files

### **4. Enable Services di Firebase Console**

#### **Authentication:**
1. Firebase Console → **Authentication**
2. **Get started**
3. **Email/Password** → Enable → Save

#### **Firestore:**
1. Firebase Console → **Firestore Database**
2. **Create database**
3. **Test mode** → Next
4. Location: **asia-southeast1** → Enable

#### **Storage:**
1. Firebase Console → **Storage**
2. **Get started**
3. **Test mode** → Done

### **5. Update main.dart**

Ganti:
```dart
await Firebase.initializeApp();
```

Dengan:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### **6. Enable Firebase in App**

Tambahkan toggle di settings atau login screen:

```dart
// Enable Firebase authentication
final authProvider = context.read<AuthProvider>();
authProvider.setUseFirebase(true);
```

### **7. Run App**

```bash
flutter pub get
flutter run
```

✅ **DONE!** Aplikasi sekarang menggunakan Firebase.

---

## 🧪 Testing Firebase

### **Register New User**

1. Buka app → Register screen
2. Isi form → Register
3. Check Firebase Console → Authentication → Users
4. User baru harus muncul ✅

### **Check Firestore**

1. Firebase Console → Firestore
2. Collection `users` harus ada dengan data user ✅

### **Upload Image (if implemented)**

1. Create report with image
2. Check Firebase Console → Storage
3. Image harus muncul di folder `reports` ✅

---

## 🔧 Troubleshooting

### **Error: "No Firebase App"**

```bash
# Make sure you ran:
flutterfire configure
```

### **Error: "minSdkVersion"**

Edit `android/app/build.gradle`:
```gradle
minSdkVersion 21  // Change from 16 to 21
```

### **Error: "Multidex"**

Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    multiDexEnabled true
}
```

### **Firebase Not Working But App Runs**

App berjalan dalam **mock mode**. Check console log:
```
✅ Firebase initialized successfully  → Firebase active
⚠️ Firebase initialization failed    → Mock mode active
```

---

## 📊 What You Get with Firebase

### **Mock Mode (Default)**
- ✅ Local authentication
- ✅ Data stored in SharedPreferences
- ❌ No cloud sync
- ❌ No multi-device sync
- ❌ No real-time updates

### **Firebase Mode**
- ✅ Real authentication
- ✅ Cloud Firestore database
- ✅ Cloud Storage for images
- ✅ Multi-device sync
- ✅ Real-time updates
- ✅ Scalable to production

---

## 🎯 Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules (see `FIREBASE_SETUP.md`)
- [ ] Update Storage security rules
- [ ] Enable Firebase App Check
- [ ] Setup Firebase Analytics
- [ ] Configure Firebase Performance Monitoring
- [ ] Setup Firebase Crashlytics
- [ ] Test on real devices
- [ ] Setup CI/CD pipeline

---

## 📚 Next Steps

1. ✅ **Setup Firebase** (5 minutes)
2. 📖 Read `FIREBASE_SETUP.md` for detailed configuration
3. 📖 Read `DEVELOPMENT_GUIDE.md` for development workflow
4. 🔒 Configure security rules for production
5. 🚀 Deploy to PlayStore/AppStore

---

## 🆘 Need Help?

- Detailed setup: `FIREBASE_SETUP.md`
- Development guide: `DEVELOPMENT_GUIDE.md`
- Firebase docs: [firebase.flutter.dev](https://firebase.flutter.dev)
- Flutter docs: [flutter.dev](https://flutter.dev)

---

**Selamat Coding! 🎉**
