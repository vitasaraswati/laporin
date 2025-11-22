# 🛡️ Admin Dashboard - Panduan Lengkap

## 📋 Daftar Isi
1. [Overview](#overview)
2. [Fitur Utama](#fitur-utama)
3. [UI Components](#ui-components)
4. [Navigasi](#navigasi)
5. [Quick Actions](#quick-actions)
6. [Tab Management](#tab-management)
7. [Permissions](#permissions)
8. [Best Practices](#best-practices)

---

## Overview

**Admin Dashboard Screen** adalah panel kontrol khusus untuk admin/dosen yang memiliki wewenang untuk mengelola laporan. Dashboard ini menyediakan overview statistik, filtering berdasarkan status, dan quick actions untuk approve/reject laporan.

### File Location
```
lib/screens/admin_dashboard_screen.dart
```

### Access Requirements
- **Role**: Admin atau Dosen
- **Permission**: `canManageReports()` harus return `true`

---

## Fitur Utama

### 1. **Statistics Overview** 📊
Card statistik yang menampilkan ringkasan laporan:
- **Total**: Jumlah semua laporan
- **Pending**: Laporan menunggu persetujuan (warna kuning/warning)
- **Proses**: Laporan sedang dikerjakan (warna biru/info)
- **Selesai**: Laporan yang sudah selesai (warna hijau/success)

**Animasi**: Fade in + slide up saat tampil pertama kali.

### 2. **Tab Filtering** 🗂️
5 tab untuk filtering laporan berdasarkan status:
- **Semua**: Menampilkan semua laporan tanpa filter
- **Pending**: Hanya laporan dengan status `pending`
- **Disetujui**: Hanya laporan dengan status `approved`
- **Proses**: Hanya laporan dengan status `inProgress`
- **Selesai**: Hanya laporan dengan status `resolved`

**Fitur**:
- Tab scrollable (horizontal scroll jika terlalu panjang)
- Active indicator (garis putih tebal di bawah tab aktif)
- Smooth animation saat switch tab

### 3. **Report Cards** 📝
Setiap laporan ditampilkan dalam card dengan informasi lengkap:

**Header**:
- Colored stripe di atas sesuai status
- Icon kategori di dalam container rounded
- Judul laporan (max 1 line, ellipsis)
- Status badge di pojok kanan atas

**Content**:
- Deskripsi singkat (max 2 lines)
- Info reporter (avatar, nama, role badge)
- Priority flag badge
- Timestamp relatif (contoh: "2j lalu", "Kemarin")
- Lokasi laporan (jika ada)

**Quick Actions** (muncul di card sesuai status):
- **Pending**: Tombol "Tolak" (merah) dan "Setujui" (hijau)
- **Approved**: Tombol "Mulai Proses" (biru)
- **In Progress**: Tombol "Selesaikan" (hijau)

**Animasi**: Staggered fade in + slide dari kiri (delay 50ms per card).

### 4. **Empty States** 🗃️
Jika tidak ada laporan pada tab tertentu:
- Icon inbox besar
- Teks "Tidak ada laporan"
- Deskripsi sesuai filter yang aktif

### 5. **Error Handling** ⚠️
Jika terjadi error saat fetch data:
- Icon error besar (merah)
- Error message
- Tombol "Coba Lagi" untuk retry

---

## UI Components

### Statistics Card (Mini)
```dart
Container(
  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  decoration: BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: statusColor.withOpacity(0.3)),
  ),
  child: Column(
    - Icon (24px)
    - Value (H3, bold, colored)
    - Label (Caption, 10px)
  ),
)
```

### Report Card Structure
```
Card
├── Colored Stripe (6px height, status color)
├── Padding (16px)
│   ├── Category Icon + Title + Status Badge
│   ├── Description (2 lines max)
│   ├── Reporter Info Row
│   │   ├── Avatar (28px)
│   │   ├── Name + Role
│   │   └── Priority Badge
│   ├── Footer (timestamp + location)
│   └── Quick Actions (conditional)
```

---

## Navigasi

### 1. **Akses ke Admin Dashboard**
Ada 3 cara untuk masuk ke Admin Dashboard:

#### A. Dari Profile Drawer
```dart
// Menu: "Admin Dashboard"
// Icon: admin_panel_settings_outlined
// Kondisi: authProvider.canManageReports()
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
);
```

#### B. Dari Home Dashboard (Quick Access Card)
Card gradient biru yang muncul di atas Statistics Cards (hanya untuk admin):
```dart
// Tap card untuk navigate
// Animasi: Fade in + slide dari kiri
```

#### C. Direct Navigation
```dart
// Dari screen manapun
context.go('/admin-dashboard'); // jika pakai go_router
// atau
Navigator.pushNamed(context, '/admin-dashboard');
```

### 2. **Navigasi dari Admin Dashboard**
- **Tap Report Card**: Buka `ReportDetailScreen` dengan reportId
- **Back Button**: Kembali ke screen sebelumnya

---

## Quick Actions

### 1. **Approve Report** ✅
**Trigger**: Tombol "Setujui" pada pending report

**Flow**:
1. Tampilkan dialog konfirmasi dengan judul laporan
2. User klik "Setujui" atau "Batal"
3. Jika setujui:
   - Call `reportProvider.approveReport(reportId, adminId)`
   - Tampilkan SnackBar success (hijau)
   - Refresh data dengan `fetchReports()`
4. Jika gagal:
   - Tampilkan SnackBar error (merah) dengan error message

**Code**:
```dart
Future<void> _quickApprove(Report report) async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  
  final adminId = context.read<AuthProvider>().currentUser?.id;
  final success = await reportProvider.approveReport(reportId, adminId);
  
  // Handle success/error dengan SnackBar
}
```

### 2. **Reject Report** ❌
**Trigger**: Tombol "Tolak" pada pending report

**Flow**:
1. Tampilkan dialog dengan TextField untuk alasan penolakan
2. Validasi: Alasan tidak boleh kosong
3. User klik "Tolak" atau "Batal"
4. Jika tolak:
   - Call `reportProvider.rejectReport(reportId, note)`
   - Tampilkan SnackBar success
   - Refresh data

**Code**:
```dart
Future<void> _quickReject(Report report) async {
  final note = await showDialog<String>(...); // Dialog dengan TextField
  if (note == null || note.isEmpty) return;
  
  final success = await reportProvider.rejectReport(reportId, note);
  
  // Handle success/error
}
```

### 3. **Change Status** 🔄
**Trigger**: 
- Tombol "Mulai Proses" pada approved report
- Tombol "Selesaikan" pada in-progress report

**Flow**:
1. Tampilkan dialog konfirmasi dengan status baru
2. User klik "Ya" atau "Batal"
3. Jika ya:
   - Call `reportProvider.updateReportStatus(reportId, newStatus)`
   - Tampilkan SnackBar success
   - Refresh data

**Code**:
```dart
Future<void> _quickChangeStatus(Report report, ReportStatus newStatus) async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  
  final success = await reportProvider.updateReportStatus(reportId, newStatus);
  
  // Handle success/error
}
```

---

## Tab Management

### Tab Controller
```dart
late TabController _tabController;

@override
void initState() {
  _tabController = TabController(length: 5, vsync: this);
  // Load data
  context.read<ReportProvider>().fetchReports();
}

@override
void dispose() {
  _tabController.dispose();
  super.dispose();
}
```

### Tab Configuration
```dart
TabBar(
  controller: _tabController,
  isScrollable: true, // Enable horizontal scroll
  indicatorColor: white,
  indicatorWeight: 3,
  tabs: [
    Tab(text: 'Semua'),
    Tab(text: 'Pending'),
    Tab(text: 'Disetujui'),
    Tab(text: 'Proses'),
    Tab(text: 'Selesai'),
  ],
)
```

### Tab Content
```dart
TabBarView(
  controller: _tabController,
  children: [
    _buildReportList(reportProvider, null), // Semua
    _buildReportList(reportProvider, ReportStatus.pending),
    _buildReportList(reportProvider, ReportStatus.approved),
    _buildReportList(reportProvider, ReportStatus.inProgress),
    _buildReportList(reportProvider, ReportStatus.resolved),
  ],
)
```

---

## Permissions

### Access Control
```dart
// Di awal build method
if (!authProvider.canManageReports()) {
  return Scaffold(
    appBar: AppBar(...),
    body: Center(
      child: Column(
        - Lock Icon
        - "Akses Ditolak"
        - "Anda tidak memiliki akses ke halaman ini"
      ),
    ),
  );
}
```

### Permission Check di Provider
```dart
// lib/providers/auth_provider.dart
bool canManageReports() {
  return currentUser?.role == UserRole.admin || 
         currentUser?.role == UserRole.dosen;
}
```

### Menu Visibility
```dart
// lib/widgets/profile_drawer.dart
if (authProvider.canManageReports())
  ListTile(
    title: 'Admin Dashboard',
    onTap: () => Navigator.push(...),
  ),
```

---

## Best Practices

### 1. **Performance**
- ✅ Gunakan `shrinkWrap: true` untuk GridView di dalam ScrollView
- ✅ Set `physics: NeverScrollableScrollPhysics()` untuk nested scroll
- ✅ Dispose TabController di `dispose()` method
- ✅ Gunakan `const` constructor dimana memungkinkan

### 2. **User Experience**
- ✅ Tampilkan loading indicator saat fetch data
- ✅ Berikan feedback dengan SnackBar setelah action
- ✅ Animasi smooth untuk transisi (fade in, slide)
- ✅ Konfirmasi dialog sebelum action penting (approve/reject)
- ✅ Error handling dengan pesan yang jelas

### 3. **Code Organization**
- ✅ Pisahkan widget builder menjadi method private (`_buildXxx`)
- ✅ Extract helper methods (`_formatDate`, `_getStatusColor`)
- ✅ Gunakan Consumer untuk state management
- ✅ Async/await untuk operations yang membutuhkan waktu

### 4. **State Management**
- ✅ Refresh data setelah action berhasil (`fetchReports()`)
- ✅ Check mounted sebelum update UI setelah async operation
- ✅ Use context.read() untuk one-time operation
- ✅ Use context.watch() untuk reactive updates

### 5. **Error Handling**
```dart
if (mounted) {
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil'), backgroundColor: success),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: error),
    );
  }
}
```

---

## Color Coding System

### Status Colors
```dart
ReportStatus.pending    -> AppColors.warning  (Kuning)
ReportStatus.approved   -> AppColors.info     (Biru)
ReportStatus.inProgress -> AppColors.primary  (Biru Tua)
ReportStatus.resolved   -> AppColors.success  (Hijau)
ReportStatus.rejected   -> AppColors.error    (Merah)
```

### Priority Colors
```dart
ReportPriority.low     -> AppColors.success (Hijau)
ReportPriority.medium  -> AppColors.info    (Biru)
ReportPriority.high    -> AppColors.warning (Kuning)
ReportPriority.urgent  -> AppColors.error   (Merah)
```

### Role Colors
```dart
UserRole.mahasiswa -> AppColors.info    (Biru)
UserRole.dosen     -> AppColors.success (Hijau)
UserRole.admin     -> AppColors.error   (Merah)
```

---

## Animations

### 1. **Statistics Overview**
```dart
.animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: -0.1, end: 0)
```

### 2. **Report Cards**
```dart
.animate(delay: (index * 50).ms) // Staggered
  .fadeIn(duration: 300.ms)
  .slideX(begin: 0.2, end: 0)
```

### 3. **Quick Access Card (Home)**
```dart
.animate()
  .fadeIn(duration: 400.ms)
  .slideX(begin: -0.2, end: 0)
```

---

## Testing Tips

### 1. **Test dengan Mock Data**
ReportProvider sudah menyediakan `_generateMockReports()` untuk testing.

### 2. **Test Scenarios**
- ✅ Admin login dan akses dashboard
- ✅ Mahasiswa login dan coba akses (harus ditolak)
- ✅ Approve laporan pending
- ✅ Reject laporan dengan alasan
- ✅ Change status approved → in progress → resolved
- ✅ Scroll horizontal pada tabs
- ✅ Pull to refresh
- ✅ Tap card untuk detail
- ✅ Empty state pada setiap tab
- ✅ Error state dan retry

### 3. **Edge Cases**
- ❌ User bukan admin coba akses
- ❌ Network error saat approve
- ❌ Reject tanpa alasan
- ❌ Report sudah tidak bisa di-approve (status berubah)

---

## Future Enhancements

### 1. **Bulk Actions**
Tambah checkbox untuk select multiple reports dan action sekaligus:
```dart
- Select All checkbox
- Approve selected
- Reject selected
- Change status selected
```

### 2. **Advanced Filtering**
Filter tambahan selain status:
```dart
- By Category
- By Priority
- By Date Range
- By Reporter
```

### 3. **Export Reports**
Export data laporan ke PDF/Excel:
```dart
- Export tab aktif
- Export semua laporan
- Export dengan custom filter
```

### 4. **Analytics Charts**
Visualisasi data dengan chart:
```dart
- Pie chart by category
- Line chart by date
- Bar chart by status
```

### 5. **Real-time Updates**
WebSocket untuk live updates:
```dart
- New report notification
- Status change notification
- Auto refresh list
```

### 6. **Search Functionality**
Tambah search bar di atas tabs:
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Cari laporan...',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (query) => reportProvider.setSearchQuery(query),
)
```

---

## Troubleshooting

### Issue: "Akses Ditolak" muncul padahal user admin
**Solution**: 
- Check `authProvider.currentUser?.role`
- Pastikan role adalah `UserRole.admin` atau `UserRole.dosen`
- Check implementation `canManageReports()` di AuthProvider

### Issue: Quick action tidak work
**Solution**:
- Check mounted sebelum showDialog
- Pastikan adminId tidak null
- Check ReportProvider method return value

### Issue: Tab content tidak update setelah action
**Solution**:
- Call `reportProvider.fetchReports()` setelah action berhasil
- Pastikan Consumer mendengarkan perubahan
- Check `notifyListeners()` di ReportProvider

### Issue: Animation lag
**Solution**:
- Reduce staggered delay (50ms → 30ms)
- Use `const` constructor untuk widget statis
- Optimize nested ScrollView dengan `shrinkWrap`

---

## Summary

Admin Dashboard adalah fitur powerful untuk mengelola laporan dengan:
- ✅ **Statistics Overview** untuk monitoring cepat
- ✅ **Tab Filtering** untuk organizing laporan
- ✅ **Quick Actions** untuk approve/reject dengan cepat
- ✅ **Beautiful UI** dengan gradient, animations, dan color coding
- ✅ **Permission Control** untuk keamanan akses
- ✅ **Error Handling** yang proper
- ✅ **Responsive** dan smooth animations

Dashboard ini dirancang untuk memberikan pengalaman admin yang efisien dan modern! 🎉
