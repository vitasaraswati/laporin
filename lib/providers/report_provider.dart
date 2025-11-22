import 'package:flutter/foundation.dart';
import 'package:laporin/models/report_model.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/models/location_model.dart';
import 'package:laporin/models/media_model.dart';
import 'package:laporin/services/firestore_service.dart';
import 'dart:async';

class ReportProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Report> _reports = [];
  Report? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _reportsSubscription;

  // Filters
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;
  String? _searchQuery;

  List<Report> get reports => _getFilteredReports();
  List<Report> get allReports => _reports;
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

  // Get report statistics (sync - from cached data)
  Map<String, int> getReportStats() {
    return {
      'all': _reports.length,
      'total': _reports.length,
      'inProgress': _reports.where((r) => r.status == ReportStatus.inProgress).length,
      'approved': _reports.where((r) => r.status == ReportStatus.approved).length,
      'rejected': _reports.where((r) => r.status == ReportStatus.rejected).length,
    };
  }

  // Get report statistics from Firestore (async)
  Future<Map<String, int>> fetchReportStatsFromFirestore() async {
    try {
      return await _firestoreService.getReportStatistics();
    } catch (e) {
      // Return cached stats if Firestore fails
      return getReportStats();
    }
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

  // Fetch all reports from Firestore
  Future<void> fetchReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription
      await _reportsSubscription?.cancel();

      // Listen to reports stream from Firestore
      _reportsSubscription = _firestoreService.getReports().listen(
        (reports) {
          _reports = reports;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage = 'Gagal memuat laporan: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat laporan: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dispose subscription
  @override
  void dispose() {
    _reportsSubscription?.cancel();
    super.dispose();
  }

  // Fetch report by ID
  Future<Report?> fetchReportById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First try from cache
      final cachedReport = _reports.where((r) => r.id == id).firstOrNull;
      if (cachedReport != null) {
        _selectedReport = cachedReport;
        _isLoading = false;
        notifyListeners();
        return _selectedReport;
      }

      // Fetch from Firestore
      _selectedReport = await _firestoreService.getReportById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedReport;
    } catch (e) {
      _errorMessage = 'Gagal memuat detail laporan: $e';
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
      final newReport = Report(
        id: '', // Will be assigned by Firestore
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: ReportStatus.inProgress,
        reporter: reporter,
        location: location,
        media: media ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create in Firestore
      await _firestoreService.createReport(newReport);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat laporan: $e';
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
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category.name;
      if (priority != null) updates['priority'] = priority.name;

      await _firestoreService.updateReport(reportId, updates);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate laporan: $e';
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
      await _firestoreService.updateReport(reportId, {
        'status': ReportStatus.approved.name,
        'approved_by': adminId,
        'approved_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyetujui laporan: $e';
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
      await _firestoreService.updateReport(reportId, {
        'status': ReportStatus.rejected.name,
        'admin_note': adminNote,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menolak laporan: $e';
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
      await _firestoreService.updateReportStatus(reportId, newStatus);

      if (note != null) {
        await _firestoreService.updateReport(reportId, {'admin_note': note});
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate status laporan: $e';
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
      await _firestoreService.deleteReport(reportId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus laporan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
