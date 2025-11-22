# 🔐 Akun Test untuk Login

## Akun yang Tersedia

### 1. 👨‍💼 Admin / Staff
```
Email    : admin@laporin.com
Password : admin123
Role     : Admin
NIP      : 198501012010011001
```

**Akses:**
- ✅ Melihat semua laporan
- ✅ Menyetujui laporan
- ✅ Menolak laporan
- ✅ Mengubah status laporan
- ✅ Dashboard admin
- ✅ Statistik lengkap
- ❌ Tidak bisa membuat laporan baru

---

### 2. 👨‍🎓 Mahasiswa
```
Email    : mahasiswa@student.polinema.ac.id
Password : mahasiswa123
Role     : Mahasiswa
NIM      : 2341720001
```

**Akses:**
- ✅ Membuat laporan baru
- ✅ Melihat laporan sendiri
- ✅ Mengedit laporan (status: Diproses)
- ✅ Menghapus laporan (status: Diproses)
- ✅ Melacak status laporan
- ❌ Tidak bisa approve/reject

---

### 3. 👩‍🏫 Dosen
```
Email    : dosen@polinema.ac.id
Password : dosen123
Role     : Dosen
NIP      : 198203152006042001
```

**Akses:**
- ✅ Membuat laporan baru
- ✅ Melihat laporan sendiri
- ✅ Mengedit laporan (status: Diproses)
- ✅ Menghapus laporan (status: Diproses)
- ✅ Melacak status laporan
- ❌ Tidak bisa approve/reject

---

## 📱 Cara Login

1. Buka aplikasi Laporin
2. Pada halaman login, masukkan email dan password
3. Klik tombol "Masuk"
4. Aplikasi akan otomatis mengarahkan sesuai role

---

## 🔍 Perbedaan Akses Berdasarkan Role

| Fitur | Admin | Mahasiswa | Dosen |
|-------|-------|-----------|-------|
| Buat Laporan | ❌ | ✅ | ✅ |
| Edit Laporan (Diproses) | ❌ | ✅ | ✅ |
| Hapus Laporan (Diproses) | ❌ | ✅ | ✅ |
| Lihat Semua Laporan | ✅ | ✅ | ✅ |
| Approve Laporan | ✅ | ❌ | ❌ |
| Reject Laporan | ✅ | ❌ | ❌ |
| Dashboard Admin | ✅ | ❌ | ❌ |
| Statistik Lengkap | ✅ | Pribadi | Pribadi |

---

## 🎯 Status Laporan

### Untuk Pelapor (Mahasiswa/Dosen):
- **Diproses** → Dapat edit & hapus
- **Disetujui** → Read-only
- **Ditolak** → Read-only

### Untuk Admin:
- **Diproses** → Dapat approve/reject
- **Disetujui** → Dapat ubah ke diproses lagi
- **Ditolak** → Final

---

## 🔄 Flow Testing

### Test Admin:
1. Login dengan akun admin
2. Lihat dashboard admin (ada tab Semua, Diproses, Disetujui, Ditolak)
3. Klik laporan dengan status "Diproses"
4. Klik tombol menu (⋮) di kanan atas
5. Pilih "Setujui" atau "Tolak"
6. Laporan berubah status

### Test Mahasiswa/Dosen:
1. Login dengan akun mahasiswa/dosen
2. Klik tombol "Tambah Laporan" (FAB kanan bawah)
3. Isi form dan submit
4. Lihat laporan di halaman "Laporan Saya"
5. Klik laporan dengan status "Diproses"
6. Klik tombol menu (⋮) di kanan atas
7. Pilih "Edit" atau "Hapus"

---

## 💡 Tips Testing

1. **Login/Logout Cepat:**
   - Buka halaman Profile
   - Klik "Keluar dari Akun"
   - Login dengan akun berbeda

2. **Test Role Switching:**
   - Login sebagai mahasiswa → buat laporan
   - Logout → login sebagai admin → approve
   - Logout → login sebagai mahasiswa → cek status

3. **Test Permission:**
   - Coba akses fitur yang tidak diizinkan
   - Verifikasi tombol/menu yang hidden

4. **Test CRUD:**
   - Create: Buat laporan baru
   - Read: Lihat detail laporan
   - Update: Edit laporan (status Diproses)
   - Delete: Hapus laporan (status Diproses)

---

## ⚠️ Catatan Penting

- Semua akun test menggunakan **mock data** (tidak tersimpan ke database real)
- Data akan **hilang** saat aplikasi di-restart
- Password minimal **6 karakter**
- Email harus **format valid**
- Untuk testing production, gunakan akun lain selain yang di atas

---

## 🚀 Development Mode

Jika ingin membuat akun custom saat development:
```
Email    : [email-anda]@domain.com
Password : [min. 6 karakter]
Role     : [Pilih saat login]
```

Sistem akan otomatis generate:
- User ID
- NIM (untuk mahasiswa)
- NIP (untuk dosen)
- Timestamp

---

**Update:** 13 November 2025
**Developer:** Laporin Team
