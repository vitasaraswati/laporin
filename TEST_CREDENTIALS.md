# 🔐 Test Credentials - LaporJTI

## 📝 Informasi Penting

**Status Saat Ini**: Aplikasi menggunakan **MOCK AUTHENTICATION** (belum terintegrasi dengan backend real).

Artinya, Anda bisa login dengan **email dan password apapun** selama memenuhi syarat:
- ✅ Email harus format valid (contoh: `user@example.com`)
- ✅ Password minimal 6 karakter

---

## 🎭 Cara Login Berdasarkan Role

### Sistem Login Saat Ini

✅ **UPDATE**: Register Screen sudah dilengkapi dengan **dropdown pemilihan role** dan **field kondisional NIM/NIP**!

**Cara Mudah untuk Testing:**
1. Buka Register Screen
2. Pilih role dari dropdown (Admin/Dosen/Mahasiswa)
3. Isi field yang sesuai dengan role:
   - **Mahasiswa**: Field NIM wajib (10 digit)
   - **Dosen**: Field NIP wajib (18 digit)
   - **Admin**: Tidak perlu NIM/NIP
4. Submit → Otomatis login dengan role yang dipilih

---

## 🚀 Testing Admin Dashboard

### ✅ Cara Register sebagai Admin (MUDAH!)

1. **Buka aplikasi** → Klik "Daftar"
2. **Isi form register:**
   ```
   Nama     : Admin JTI
   Email    : admin@jti.polinema.ac.id
   Password : admin123
   Role     : Admin ✅ (pilih dari dropdown)
   Telepon  : 081234567890 (opsional)
   ```
3. **Submit** → Otomatis login sebagai admin
4. **Akses Admin Dashboard:**
   - Dari Drawer (sidebar) → Menu "Admin Dashboard"
   - Dari Home → Card gradient biru "Admin Dashboard"

### Tidak Perlu Lagi Modifikasi Kode! 🎉

Dropdown role sudah tersedia di Register Screen dengan:
- ✅ Icon role dengan warna berbeda
- ✅ Field NIM otomatis muncul untuk Mahasiswa
- ✅ Field NIP otomatis muncul untuk Dosen
- ✅ Validasi otomatis sesuai role

---

## 📋 Contoh Kredensial untuk Testing

### 1️⃣ Admin

**Register sebagai Admin:**
```
Nama     : Admin JTI
Email    : admin@jti.polinema.ac.id
Password : admin123
Role     : Admin (pilih dari dropdown)
Telepon  : 081234567890 (opsional)
```

**Atau:**
```
Nama     : Super Admin
Email    : admin@test.com
Password : admin123
Role     : Admin
Telepon  : - (kosongkan saja)
```

**Akses:**
- ✅ Bisa membuat laporan
- ✅ Bisa melihat semua laporan
- ✅ Bisa approve/reject laporan
- ✅ Bisa akses Admin Dashboard
- ✅ Bisa mengubah status laporan
- ✅ Tidak perlu NIM/NIP

---

### 2️⃣ Dosen

**Register sebagai Dosen:**
```
Nama     : Dr. Budi Santoso
Email    : dosen@jti.polinema.ac.id
Password : dosen123
Role     : Dosen (pilih dari dropdown)
NIP      : 198512345678901234 (18 digit) ✅
Telepon  : 081234567891 (opsional)
```

**Atau:**
```
Nama     : Prof. Siti Nurhaliza
Email    : siti.nurhaliza@polinema.ac.id
Password : dosen123
Role     : Dosen
NIP      : 199001234567890123 (18 digit)
Telepon  : - (kosongkan saja)
```

**Akses:**
- ✅ Bisa membuat laporan
- ✅ Bisa melihat semua laporan
- ✅ Bisa approve/reject laporan
- ✅ Bisa akses Admin Dashboard
- ✅ Bisa mengubah status laporan
- ✅ Wajib isi NIP 18 digit

---

### 3️⃣ Mahasiswa

**Register sebagai Mahasiswa:**
```
Nama     : Andi Pratama
Email    : mahasiswa@student.polinema.ac.id
Password : mhs123456
Role     : Mahasiswa (pilih dari dropdown)
NIM      : 2341720001 (10 digit) ✅
Telepon  : 081234567892 (opsional)
```

**Atau:**
```
Nama     : Dewi Lestari
Email    : dewi.lestari@student.polinema.ac.id
Password : dewi12345
Role     : Mahasiswa
NIM      : 2341720123 (10 digit)
Telepon  : - (kosongkan saja)
```

**Akses:**
- ✅ Bisa membuat laporan
- ✅ Bisa melihat laporan sendiri
- ❌ TIDAK bisa approve/reject
- ❌ TIDAK bisa akses Admin Dashboard
- ❌ TIDAK bisa mengubah status laporan orang lain
- ✅ Wajib isi NIM 10 digit

---

## 🔍 Validasi Email & Password

### Format Email Valid:
```
✅ admin@jti.polinema.ac.id
✅ user@example.com
✅ test.user@domain.co.id
✅ mahasiswa@student.polinema.ac.id

❌ admin (tanpa @)
❌ admin@ (tanpa domain)
❌ @jti.polinema.ac.id (tanpa username)
```

### Password Requirements:
```
✅ Minimal 6 karakter
✅ Boleh kombinasi huruf, angka, simbol
✅ Case-sensitive (Admin123 ≠ admin123)

Contoh Valid:
✅ admin123
✅ 123456
✅ Password1!
✅ Test@123

Contoh Invalid:
❌ 12345 (kurang dari 6)
❌ admin (kurang dari 6)
```

---

## 🎯 Flow Testing Lengkap

### Scenario 1: Test Admin Flow ✅

```
1. REGISTER sebagai Admin
   → Klik "Daftar" di Login Screen
   → Nama: Admin JTI
   → Email: admin@jti.polinema.ac.id
   → Password: admin123
   → Role: Pilih "Admin" dari dropdown ✅
   → Telepon: 081234567890 (opsional)
   → Centang "Syarat dan Ketentuan"
   → Klik "Daftar"

2. OTOMATIS LOGIN
   → Redirect ke Home Screen
   → Lihat Quick Access Card "Admin Dashboard" (gradient biru) ✅
   → Menu drawer ada "Admin Dashboard" ✅

3. BUKA ADMIN DASHBOARD
   → Klik Quick Access Card
   → ATAU buka Drawer → "Admin Dashboard"

4. TEST FITUR ADMIN
   → Lihat Statistics Overview (Total, Pending, Proses, Selesai)
   → Switch antar tabs (Semua, Pending, Disetujui, Proses, Selesai)
   → Approve laporan pending dengan klik "Setujui"
   → Reject laporan dengan klik "Tolak" dan isi alasan
   → Change status (Approved → "Mulai Proses" → "Selesaikan")
   → Refresh dengan pull-to-refresh
   → Tap report card untuk lihat detail
```

### Scenario 2: Test Mahasiswa Flow ✅

```
1. REGISTER sebagai Mahasiswa
   → Klik "Daftar"
   → Nama: Andi Pratama
   → Email: andi@student.polinema.ac.id
   → Password: andi123
   → Role: Pilih "Mahasiswa" dari dropdown ✅
   → NIM: 2341720123 (10 digit) ✅ (field otomatis muncul)
   → Telepon: 081234567892 (opsional)
   → Submit

2. LOGIN
   → Dashboard hanya menampilkan laporan sendiri
   → TIDAK ada Quick Access Card "Admin Dashboard" ❌
   → TIDAK ada menu "Admin Dashboard" di Drawer ❌

3. COBA AKSES ADMIN DASHBOARD (Manual)
   → Jika berhasil navigate manual
   → Akan muncul screen "Akses Ditolak" ✅
   → Icon lock, pesan error

4. TEST FITUR MAHASISWA
   → Buat laporan dari FAB
   → Lihat laporan sendiri di tab Reports
   → Tap detail untuk lihat info lengkap
   → TIDAK ada tombol approve/reject ❌
```

### Scenario 3: Test Dosen Flow ✅

```
1. REGISTER sebagai Dosen
   → Klik "Daftar"
   → Nama: Dr. Budi Santoso
   → Email: dosen@jti.polinema.ac.id
   → Password: dosen123
   → Role: Pilih "Dosen" dari dropdown ✅
   → NIP: 198512345678901234 (18 digit) ✅ (field otomatis muncul)
   → Telepon: 081234567891 (opsional)
   → Submit

2. LOGIN
   → Sama seperti Admin
   → Ada Quick Access Card "Admin Dashboard" ✅
   → Ada menu "Admin Dashboard" di Drawer ✅

3. TEST ADMIN FEATURES
   → Semua fitur admin tersedia
   → Bisa approve/reject laporan
   → Bisa change status
   → Bisa akses Admin Dashboard
```

### Scenario 4: Test Field Validation ✅

```
1. TEST ROLE SWITCHING
   → Pilih "Mahasiswa" → Field NIM muncul ✅
   → Pilih "Dosen" → Field NIP muncul, NIM hilang ✅
   → Pilih "Admin" → NIM dan NIP hilang ✅

2. TEST NIM VALIDATION (Mahasiswa)
   → Kosong → Error: "NIM tidak boleh kosong" ❌
   → 9 digit → Error: "NIM harus 10 digit" ❌
   → Huruf → Error: "NIM harus berupa angka" ❌
   → 2341720123 → Valid ✅

3. TEST NIP VALIDATION (Dosen)
   → Kosong → Error: "NIP tidak boleh kosong" ❌
   → 17 digit → Error: "NIP harus 18 digit" ❌
   → Huruf → Error: "NIP harus berupa angka" ❌
   → 198512345678901234 → Valid ✅

4. TEST PHONE VALIDATION
   → Kosong → Valid (opsional) ✅
   → 9 digit → Error: "Minimal 10 digit" ❌
   → Huruf → Error: "Tidak valid" ❌
   → 081234567890 → Valid ✅
```

---

## ⚙️ Konfigurasi Mock Authentication

**File**: `lib/providers/auth_provider.dart`

```dart
// Login method
Future<bool> login(String email, String password, {UserRole? role}) async {
  // Validasi
  if (!_isValidEmail(email)) return false;
  if (password.length < 6) return false;

  // Role default: Mahasiswa
  final userRole = role ?? UserRole.mahasiswa;

  // Auto-generate NIM/NIP
  _currentUser = User(
    id: userId,
    name: email.split('@')[0],
    email: email,
    role: userRole,
    nim: userRole == UserRole.mahasiswa ? '2341720...' : null,
    nip: userRole == UserRole.dosen ? '198...' : null,
  );

  // Save to SharedPreferences
  await _saveUserData(_currentUser!);
  
  return true;
}
```

---

## 🔧 Cara Update Role untuk Testing

### ✅ Option 1: Gunakan Register Screen (RECOMMENDED)

Register screen sudah dilengkapi dengan dropdown pemilihan role!

**Fitur yang tersedia:**
- ✅ Dropdown role dengan 3 pilihan (Admin, Dosen, Mahasiswa)
- ✅ Icon warna berbeda untuk setiap role
- ✅ Field NIM otomatis muncul saat pilih Mahasiswa
- ✅ Field NIP otomatis muncul saat pilih Dosen
- ✅ Validasi otomatis sesuai role
- ✅ Field yang tidak perlu otomatis hilang saat switch role

**Cara Pakai:**
1. Buka Register Screen
2. Isi nama, email, password
3. **Pilih role dari dropdown** (Admin/Dosen/Mahasiswa)
4. Isi NIM (jika Mahasiswa) atau NIP (jika Dosen)
5. Submit → Otomatis login dengan role yang dipilih

### ❌ Tidak Perlu Lagi Hardcode atau Edit Kode!

Semua sudah terintegrasi dengan UI yang user-friendly.

---

## 📱 Testing Quick Reference

| Role      | Email Example                    | Password  | NIM/NIP              | Phone (Opsional) | Admin Access |
|-----------|----------------------------------|-----------|----------------------|------------------|--------------|
| Admin     | admin@jti.polinema.ac.id        | admin123  | -                    | 081234567890     | ✅ Yes       |
| Dosen     | dosen@jti.polinema.ac.id        | dosen123  | 198512345678901234 (18 digit) | 081234567891 | ✅ Yes       |
| Mahasiswa | mahasiswa@student.polinema.ac.id| mhs123456 | 2341720001 (10 digit) | 081234567892    | ❌ No        |

### Field Requirements per Role:

| Field    | Admin | Dosen      | Mahasiswa  |
|----------|-------|------------|------------|
| Nama     | ✅ Required | ✅ Required | ✅ Required |
| Email    | ✅ Required | ✅ Required | ✅ Required |
| Password | ✅ Required | ✅ Required | ✅ Required |
| Role     | ✅ Required | ✅ Required | ✅ Required |
| NIM      | ❌ Hidden   | ❌ Hidden   | ✅ Required (10 digit) |
| NIP      | ❌ Hidden   | ✅ Required (18 digit) | ❌ Hidden |
| Telepon  | ⭕ Optional | ⭕ Optional | ⭕ Optional |

---

## 🐛 Troubleshooting

### Issue: "Email tidak valid"
**Solution**: 
- Pastikan format email benar (ada @ dan domain)
- Contoh valid: `user@domain.com`

### Issue: "Password minimal 6 karakter"
**Solution**: 
- Gunakan password minimal 6 karakter
- Contoh: `123456`, `admin123`

### Issue: "Tidak ada menu Admin Dashboard"
**Solution**: 
- Pastikan login dengan role **Admin** atau **Dosen**
- Check `authProvider.currentUser?.role`
- Mahasiswa tidak bisa akses admin features

### Issue: Login berhasil tapi role salah
**Solution**: 
- Logout dulu
- Register ulang dengan role yang benar
- ATAU edit kode untuk pass role saat login

### Issue: Data tidak persist setelah restart app
**Solution**: 
- Data tersimpan di SharedPreferences
- Seharusnya persist setelah restart
- Check `_checkAuthStatus()` dipanggil di initState

---

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────┐
│         Splash Screen (2s)              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│   Check Auth Status (SharedPreferences)  │
└──┬──────────────────────────────────┬────┘
   │ Logged In                   Not Logged In
   │                                  │
   ▼                                  ▼
┌──────────────┐            ┌──────────────────┐
│ Home Screen  │            │ Onboarding (3x)  │
│              │            └────────┬─────────┘
│ - Dashboard  │                     │
│ - Reports    │                     ▼
│ - Profile    │            ┌──────────────────┐
└──────────────┘            │  Login Screen    │
                            │  - Email         │
                            │  - Password      │
                            │  - (Role?)       │ ← BELUM ADA UI
                            └────────┬─────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │ Register Screen  │
                            │  - Name          │
                            │  - Email         │
                            │  - Password      │
                            │  - Role ✅        │ ← SUDAH ADA DROPDOWN
                            │  - NIM/NIP       │
                            └────────┬─────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │  Home Screen     │
                            │                  │
                            │  IF Admin/Dosen: │
                            │  ┌─────────────┐ │
                            │  │ Quick Access│ │
                            │  │   Admin     │ │
                            │  │  Dashboard  │ │
                            │  └─────────────┘ │
                            └──────────────────┘
```

---

## 🎯 Rekomendasi

### Untuk Testing Cepat:
1. **Register** sebagai Admin di Register Screen (sudah ada dropdown role)
2. Email: `admin@test.com`, Password: `admin123`
3. Submit → Otomatis login
4. Buka Admin Dashboard dari Quick Access Card

### Untuk Production:
1. Implementasi **real API authentication**
2. Tambah **role selection** di Login Screen
3. Tambah **forgot password** feature
4. Tambah **email verification**
5. Implementasi **secure token storage**

---

## 📞 Contact

Jika ada pertanyaan atau issue, silakan dokumentasikan di:
- GitHub Issues
- Project documentation
- Developer notes

---

**Last Updated**: November 13, 2025  
**Version**: 1.0.0  
**Status**: Mock Authentication (Development)
