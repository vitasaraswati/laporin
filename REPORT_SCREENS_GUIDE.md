# Report Screens Implementation Guide

## 📱 Screens Implemented

### 1. Create Report Screen (`create_report_screen.dart`)

#### Features:
✅ **Form Input Lengkap**
- Title field (min 10 karakter)
- Description textarea (min 20 karakter)
- Category dropdown (Kerusakan, Keamanan, Kebersihan, Fasilitas, Lainnya)
- Priority dropdown (Rendah, Sedang, Tinggi, Mendesak)

✅ **Media Upload**
- Pick multiple images (max 5 gambar)
- Take photo with camera
- Preview gambar dengan thumbnail
- Remove individual images
- Counter display (x/5 gambar)

✅ **GPS Location**
- Get current location dengan Geolocator
- Reverse geocoding untuk address
- Display lat/long coordinates
- Update/remove location
- Loading state indicator

✅ **Validation**
- Form validation untuk semua field
- Minimum character validation
- Success/error messages
- Submit button dengan loading state

✅ **Animations**
- Smooth fade-in animations
- Staggered entry for each form section
- Scale animation for submit button

#### Usage:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CreateReportScreen(),
  ),
);
```

---

### 2. Report List Screen (`report_list_screen.dart`)

#### Features:
✅ **Search Functionality**
- Real-time search bar
- Search by title or description
- Clear button
- Instant filter update

✅ **Advanced Filtering**
- Filter by Status (Pending, Approved, In Progress, Resolved, Rejected)
- Filter by Category (All categories)
- Filter modal dengan chips
- Active filter badges
- Clear individual filter
- Reset all filters

✅ **Report Cards**
- Category icon dengan color badge
- Status badge dengan color coding
- Priority badge
- Reporter info dengan avatar
- Location info (if available)
- Media count (if available)
- Relative time display (baru saja, 2j lalu, kemarin, etc.)

✅ **List Features**
- Pull to refresh
- Empty state message
- Error handling dengan retry button
- Staggered card animations
- Tap to view detail

✅ **Performance**
- Lazy loading dengan ListView.builder
- Optimized filtering
- Cached provider data

#### Usage:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ReportListScreen(),
  ),
);
```

#### Filter Implementation:
```dart
// In ReportProvider
reportProvider.setStatusFilter(ReportStatus.pending);
reportProvider.setCategoryFilter(ReportCategory.kerusakan);
reportProvider.setSearchQuery('kursi');
reportProvider.clearFilters();
```

---

### 3. Report Detail Screen (`report_detail_screen.dart`)

#### Features:
✅ **Header Section**
- Gradient background dengan status color
- Large category icon
- Status badge
- Priority badge
- Title dan timestamp

✅ **Information Sections**
1. **Description** - Full report description
2. **Reporter Info** - Avatar, name, email, role badge, identifier (NIM/NIP)
3. **Location** - Map marker icon, address, coordinates (if available)
4. **Media Gallery** - Horizontal scrollable image list (if available)
5. **Status Timeline** - Visual timeline dengan icons dan timestamps
6. **Admin Note** - Warning box untuk catatan admin (if rejected)

✅ **Admin Actions** (Only for Admin)
- **Approve Button** - Setujui laporan (pending → approved)
- **Reject Button** - Tolak dengan alasan (pending → rejected)
- **Change Status** - Update status (approved → in progress → resolved)
- Confirmation dialogs
- Success/error messages

✅ **Status Timeline**
- Created milestone
- Approved milestone (with date)
- In Progress milestone (with date)
- Resolved milestone (with date)
- Rejected milestone (with date)
- Color-coded timeline
- Active/inactive states

✅ **Animations**
- Staggered section animations
- Bottom sheet slide-in for admin actions
- Smooth transitions

#### Admin Actions:
```dart
// Approve
await reportProvider.approveReport(reportId, adminId);

// Reject with note
await reportProvider.rejectReport(reportId, 'Alasan penolakan');

// Update status
await reportProvider.updateReportStatus(reportId, ReportStatus.inProgress);
```

---

## 🎨 UI/UX Features

### Color Coding System

#### Status Colors:
- **Pending**: `AppColors.warning` (Orange) - ⏳
- **Approved**: `AppColors.info` (Blue) - ✓
- **In Progress**: `AppColors.primary` (Blue) - ⟳
- **Resolved**: `AppColors.success` (Green) - ✓✓
- **Rejected**: `AppColors.error` (Red) - ✗

#### Priority Colors:
- **Rendah**: `AppColors.success` (Green)
- **Sedang**: `AppColors.info` (Blue)
- **Tinggi**: `AppColors.warning` (Orange)
- **Mendesak**: `AppColors.error` (Red)

#### Role Colors:
- **Mahasiswa**: `AppColors.primary` (Blue)
- **Dosen**: `AppColors.secondary` (Orange)
- **Admin**: `AppColors.error` (Red)

### Animations

#### Create Report Screen:
```dart
.animate().fadeIn(delay: 100.ms, duration: 300.ms)  // Staggered form fields
```

#### Report List Screen:
```dart
.animate(delay: (index * 50).ms)                    // Staggered list items
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, end: 0)
```

#### Report Detail Screen:
```dart
.animate().fadeIn(delay: 100.ms, duration: 300.ms) // Staggered sections
.animate().slideY(begin: 1, end: 0)                // Bottom sheet
```

---

## 🔗 Navigation Flow

```
Home Screen
├── FAB "Buat Laporan" → CreateReportScreen
├── "Lihat Semua" → ReportListScreen
│   └── Card Tap → ReportDetailScreen
└── Recent Report Card → ReportDetailScreen

Profile Drawer
└── "Buat Laporan" → CreateReportScreen

Bottom Navbar
└── Tab "Laporan" → ReportListScreen (embedded)
    └── Card Tap → ReportDetailScreen
```

---

## 📊 State Management

### ReportProvider Methods Used:

#### Fetch & Load:
```dart
await reportProvider.fetchReports();                // Load all reports
await reportProvider.fetchReportById(reportId);     // Load single report
```

#### Create:
```dart
await reportProvider.createReport(
  title: 'Title',
  description: 'Description',
  category: ReportCategory.kerusakan,
  priority: ReportPriority.high,
  reporter: currentUser,
  location: locationData,
  media: mediaFiles,
);
```

#### Admin Actions:
```dart
await reportProvider.approveReport(reportId, adminId);
await reportProvider.rejectReport(reportId, adminNote);
await reportProvider.updateReportStatus(reportId, newStatus);
```

#### Filtering:
```dart
reportProvider.setStatusFilter(ReportStatus.pending);
reportProvider.setCategoryFilter(ReportCategory.kerusakan);
reportProvider.setSearchQuery('search term');
reportProvider.clearFilters();
```

#### Stats:
```dart
final stats = reportProvider.getReportStats();
// Returns: {total, pending, approved, inProgress, resolved, rejected}
```

---

## 🔐 Permissions & Access Control

### Create Report Screen:
- **Mahasiswa**: ✅ Can create
- **Dosen**: ✅ Can create
- **Admin**: ❌ Cannot create (button hidden)

Check permission:
```dart
if (authProvider.canCreateReports()) {
  // Show create button
}
```

### Report Detail Screen:
- **View**: All roles can view
- **Approve/Reject**: Admin only
- **Change Status**: Admin only

Check permission:
```dart
if (authProvider.canManageReports()) {
  // Show admin actions
}
```

### Report Edit:
```dart
if (report.canBeEdited) {
  // Allow edit (pending status only)
}
```

---

## 🛠️ Technical Implementation

### Dependencies Used:

#### Image Picker:
```dart
import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();
final List<XFile> images = await picker.pickMultiImage();
final XFile? photo = await picker.pickImage(source: ImageSource.camera);
```

#### Geolocator:
```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Position position = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
);

List<Placemark> placemarks = await placemarkFromCoordinates(
  position.latitude,
  position.longitude,
);
```

#### Date Formatting:
```dart
import 'package:intl/intl.dart';

DateFormat('dd MMM yyyy').format(date);
DateFormat('dd MMM yyyy, HH:mm').format(date);
```

#### Badges:
```dart
import 'package:badges/badges.dart' as badges;

badges.Badge(
  badgeContent: Text('Text'),
  badgeStyle: badges.BadgeStyle(
    badgeColor: color,
    padding: EdgeInsets.all(4),
  ),
)
```

#### Animations:
```dart
import 'package:flutter_animate/flutter_animate.dart';

widget.animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, end: 0);
```

---

## 🐛 Error Handling

### Create Report Screen:
- ✅ Form validation errors
- ✅ Image picker errors
- ✅ Location permission errors
- ✅ Submit errors dengan SnackBar
- ✅ Loading states

### Report List Screen:
- ✅ Loading indicator
- ✅ Error state dengan retry button
- ✅ Empty state message
- ✅ Network error handling

### Report Detail Screen:
- ✅ Report not found handling
- ✅ Admin action errors
- ✅ Confirmation dialogs
- ✅ Success messages

---

## 📱 Responsive Design

### Card Layout:
- Consistent padding (16-20px)
- Rounded corners (12px)
- Elevation/shadow for depth
- Touch feedback (InkWell ripple)

### Form Layout:
- Proper spacing between fields
- Clear labels dan placeholders
- Icon indicators
- Error message display below fields

### Media Display:
- Grid layout for multiple images (3 columns)
- Horizontal scroll for detail view
- Aspect ratio maintained
- Remove button overlay

---

## ✨ Best Practices Implemented

1. **Separation of Concerns**
   - Business logic di ReportProvider
   - UI logic di Screen widgets
   - Reusable components

2. **Performance**
   - ListView.builder untuk large lists
   - Lazy loading images
   - Debounced search
   - Cached provider data

3. **User Experience**
   - Loading indicators
   - Success/error feedback
   - Confirmation dialogs
   - Empty states
   - Pull to refresh

4. **Code Quality**
   - Consistent naming
   - Clear comments
   - Type safety
   - Null safety
   - Error boundaries

5. **Accessibility**
   - Semantic labels
   - Touch targets (48x48 minimum)
   - Color contrast
   - Icon + text labels

---

## 🚀 Testing Tips

### Test Create Report:
1. Fill all fields
2. Pick multiple images
3. Get GPS location
4. Submit form
5. Check validation errors
6. Test max image limit

### Test Report List:
1. Scroll long list
2. Pull to refresh
3. Search reports
4. Apply filters
5. Tap to view detail
6. Test empty state

### Test Report Detail:
1. View all sections
2. Scroll timeline
3. Test admin actions (as admin)
4. View media gallery
5. Check permissions

### Test Permissions:
1. Login as mahasiswa - can create, cannot manage
2. Login as dosen - can create, cannot manage
3. Login as admin - cannot create, can manage

---

## 📝 Future Enhancements

### Planned Features:
- [ ] Edit report (for reporters)
- [ ] Delete report (for reporters/admin)
- [ ] Comment system
- [ ] Notifications
- [ ] Export reports (PDF/Excel)
- [ ] Analytics dashboard
- [ ] Bulk actions (admin)
- [ ] Report templates
- [ ] Photo editing before upload
- [ ] Video upload support
- [ ] Map view for location picker
- [ ] Offline support
- [ ] Push notifications

---

## 🎯 Summary

**3 Screens Implemented:**
1. ✅ Create Report Screen - Full form dengan media & GPS
2. ✅ Report List Screen - Search, filter, cards
3. ✅ Report Detail Screen - Full info dengan timeline & admin actions

**Key Features:**
- ✅ Image picker (camera & gallery)
- ✅ GPS location dengan geocoding
- ✅ Advanced filtering
- ✅ Real-time search
- ✅ Status timeline
- ✅ Admin approval workflow
- ✅ Role-based permissions
- ✅ Smooth animations
- ✅ Error handling
- ✅ Loading states

**Integration Complete:**
- ✅ Home screen navigation
- ✅ Profile drawer navigation
- ✅ Bottom navbar integration
- ✅ Provider state management
- ✅ Permission checks

**Code Quality:**
- ✅ No errors (flutter analyze passed)
- ✅ Only 4 info warnings (BuildContext, prefer_final_fields)
- ✅ Clean code structure
- ✅ Comprehensive documentation
