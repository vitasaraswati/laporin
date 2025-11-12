import 'package:flutter/foundation.dart';
import 'package:laporin/models/report_model.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/models/location_model.dart';
import 'package:laporin/models/media_model.dart';

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];
  Report? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filters
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;
  String? _searchQuery;

  List<Report> get reports => _getFilteredReports();
  Report? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReportStatus? get filterStatus => _filterStatus;
  ReportCategory? get filterCategory => _filterCategory;
  String? get searchQuery => _searchQuery;

  // Get filtered reports
  List<Report> _getFilteredReports() {
    var filtered = List<Report>.from(_reports);

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((r) => r.status == _filterStatus).toList();
    }

    // Filter by category
    if (_filterCategory != null) {
      filtered = filtered.where((r) => r.category == _filterCategory).toList();
    }

    // Filter by search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
            r.description.toLowerCase().contains(_searchQuery!.toLowerCase());
      }).toList();
    }

    // Sort by created date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  // Get reports by user
  List<Report> getReportsByUser(String userId) {
    return _reports.where((r) => r.reporter.id == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get report statistics
  Map<String, int> getReportStats() {
    return {
      'total': _reports.length,
      'pending': _reports.where((r) => r.status == ReportStatus.pending).length,
      'approved': _reports.where((r) => r.status == ReportStatus.approved).length,
      'inProgress': _reports.where((r) => r.status == ReportStatus.inProgress).length,
      'resolved': _reports.where((r) => r.status == ReportStatus.resolved).length,
      'rejected': _reports.where((r) => r.status == ReportStatus.rejected).length,
    };
  }

  // Set filters
  void setStatusFilter(ReportStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setCategoryFilter(ReportCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _filterStatus = null;
    _filterCategory = null;
    _searchQuery = null;
    notifyListeners();
  }

  // Fetch all reports
  Future<void> fetchReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // For now, generate mock data
      _reports = _generateMockReports();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat laporan';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch report by ID
  Future<Report?> fetchReportById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Find report
      _selectedReport = _reports.firstWhere(
        (r) => r.id == id,
        orElse: () => _reports.first,
      );

      _isLoading = false;
      notifyListeners();
      return _selectedReport;
    } catch (e) {
      _errorMessage = 'Gagal memuat detail laporan';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Create new report
  Future<bool> createReport({
    required String title,
    required String description,
    required ReportCategory category,
    required ReportPriority priority,
    required User reporter,
    LocationData? location,
    List<MediaFile>? media,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final newReport = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: ReportStatus.pending,
        reporter: reporter,
        location: location,
        media: media ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _reports.insert(0, newReport);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat laporan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update report (for user)
  Future<bool> updateReport(
    String reportId, {
    String? title,
    String? description,
    ReportCategory? category,
    ReportPriority? priority,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index == -1) {
        _errorMessage = 'Laporan tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _reports[index] = _reports[index].copyWith(
        title: title,
        description: description,
        category: category,
        priority: priority,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate laporan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Approve report (admin only)
  Future<bool> approveReport(String reportId, String adminId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index == -1) {
        _errorMessage = 'Laporan tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _reports[index] = _reports[index].copyWith(
        status: ReportStatus.approved,
        approvedBy: adminId,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyetujui laporan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reject report (admin only)
  Future<bool> rejectReport(String reportId, String adminNote) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index == -1) {
        _errorMessage = 'Laporan tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _reports[index] = _reports[index].copyWith(
        status: ReportStatus.rejected,
        adminNote: adminNote,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menolak laporan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update report status (admin only)
  Future<bool> updateReportStatus(String reportId, ReportStatus newStatus, {String? note}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index == -1) {
        _errorMessage = 'Laporan tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _reports[index] = _reports[index].copyWith(
        status: newStatus,
        adminNote: note,
        updatedAt: DateTime.now(),
        resolvedAt: newStatus == ReportStatus.resolved ? DateTime.now() : null,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate status laporan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete report
  Future<bool> deleteReport(String reportId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _reports.removeWhere((r) => r.id == reportId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus laporan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Generate mock data for testing
  List<Report> _generateMockReports() {
    final mockUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@student.ac.id',
      role: UserRole.mahasiswa,
      nim: '2341720001',
      createdAt: DateTime.now(),
    );

    return [
      Report(
        id: '1',
        title: 'Kursi Rusak di Ruang TI-201',
        description: 'Terdapat beberapa kursi yang kakinya patah di ruang TI-201. Mohon segera diperbaiki.',
        category: ReportCategory.kerusakan,
        priority: ReportPriority.high,
        status: ReportStatus.pending,
        reporter: mockUser,
        location: LocationData(
          latitude: -7.9458,
          longitude: 112.6186,
          buildingName: 'Gedung TI - Ruang 201',
        ),
        media: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Report(
        id: '2',
        title: 'Lampu Mati di Koridor Lantai 3',
        description: 'Lampu di koridor lantai 3 gedung TI sudah mati sejak kemarin.',
        category: ReportCategory.kerusakan,
        priority: ReportPriority.medium,
        status: ReportStatus.approved,
        reporter: mockUser,
        location: LocationData(
          latitude: -7.9458,
          longitude: 112.6186,
          buildingName: 'Gedung TI - Lantai 3',
        ),
        media: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        approvedBy: 'admin-1',
        approvedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Report(
        id: '3',
        title: 'Kebersihan Toilet Kurang Terjaga',
        description: 'Toilet di lantai 2 perlu dibersihkan lebih sering.',
        category: ReportCategory.kebersihan,
        priority: ReportPriority.low,
        status: ReportStatus.resolved,
        reporter: mockUser,
        media: [],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        approvedBy: 'admin-1',
        approvedAt: DateTime.now().subtract(const Duration(days: 2)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
