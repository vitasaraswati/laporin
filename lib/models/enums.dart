import 'package:flutter/material.dart';
import 'package:laporin/constants/colors.dart';

// User Role Enum
enum UserRole {
  mahasiswa,
  dosen,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.mahasiswa:
        return 'Mahasiswa';
      case UserRole.dosen:
        return 'Dosen';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.mahasiswa:
        return 'Dapat membuat dan melihat laporan';
      case UserRole.dosen:
        return 'Dapat membuat dan melihat laporan';
      case UserRole.admin:
        return 'Dapat mengelola dan menyetujui laporan';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.mahasiswa:
        return AppColors.primary;
      case UserRole.dosen:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.error;
    }
  }
}

// Report Category Enum
enum ReportCategory {
  kerusakan,
  keamanan,
  kebersihan,
  fasilitas,
  lainnya;

  String get displayName {
    switch (this) {
      case ReportCategory.kerusakan:
        return 'Kerusakan';
      case ReportCategory.keamanan:
        return 'Keamanan';
      case ReportCategory.kebersihan:
        return 'Kebersihan';
      case ReportCategory.fasilitas:
        return 'Fasilitas';
      case ReportCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get icon {
    switch (this) {
      case ReportCategory.kerusakan:
        return '🔧';
      case ReportCategory.keamanan:
        return '🔒';
      case ReportCategory.kebersihan:
        return '🧹';
      case ReportCategory.fasilitas:
        return '🏢';
      case ReportCategory.lainnya:
        return '📋';
    }
  }
}

// Report Status Enum
enum ReportStatus {
  pending,
  approved,
  inProgress,
  resolved,
  rejected;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Menunggu Persetujuan';
      case ReportStatus.approved:
        return 'Disetujui';
      case ReportStatus.inProgress:
        return 'Dalam Proses';
      case ReportStatus.resolved:
        return 'Selesai';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  String get color {
    switch (this) {
      case ReportStatus.pending:
        return 'warning';
      case ReportStatus.approved:
        return 'info';
      case ReportStatus.inProgress:
        return 'primary';
      case ReportStatus.resolved:
        return 'success';
      case ReportStatus.rejected:
        return 'error';
    }
  }
}

// Priority Enum
enum ReportPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case ReportPriority.low:
        return 'Rendah';
      case ReportPriority.medium:
        return 'Sedang';
      case ReportPriority.high:
        return 'Tinggi';
      case ReportPriority.urgent:
        return 'Mendesak';
    }
  }

  String get color {
    switch (this) {
      case ReportPriority.low:
        return 'success';
      case ReportPriority.medium:
        return 'info';
      case ReportPriority.high:
        return 'warning';
      case ReportPriority.urgent:
        return 'error';
    }
  }
}
