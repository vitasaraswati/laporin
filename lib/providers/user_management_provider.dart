import 'package:flutter/foundation.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/services/firestore_service.dart';
import 'package:laporin/services/firebase_auth_service.dart';

class UserManagementProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  UserRole? _filterRole;
  String _filterStatus = 'all'; // all, verified, public, admin

  // Getters
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  UserRole? get filterRole => _filterRole;
  String get filterStatus => _filterStatus;

  // Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _firestoreService.getAllUsersForManagement();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search users
  void searchUsers(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _filterRole = null;
    _filterStatus = 'all';
    _applyFilters();
    notifyListeners();
  }

  // Apply search and status filters
  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (user['email'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (user['nim'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (user['nip'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      bool matchesStatus = true;
      if (_filterStatus == 'verified') {
        // User yang punya NIM atau NIP
        matchesStatus = (user['nim'] != null && user['nim'].toString().isNotEmpty) ||
                       (user['nip'] != null && user['nip'].toString().isNotEmpty);
      } else if (_filterStatus == 'public') {
        // User yang tidak punya NIM atau NIP
        matchesStatus = (user['nim'] == null || user['nim'].toString().isEmpty) &&
                       (user['nip'] == null || user['nip'].toString().isEmpty) &&
                       user['role'] != 'admin';
      } else if (_filterStatus == 'admin') {
        // Admin users
        matchesStatus = user['role'] == 'admin';
      }
      // _filterStatus == 'all' tidak perlu filter tambahan

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Create new user
  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? nim,
    String? nip,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        nim: nim,
        nip: nip,
        phone: phone,
      );

      if (user != null) {
        await loadUsers(); // Refresh user list
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal membuat user baru';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateUserRole(userId, newRole.name);
      await loadUsers(); // Refresh user list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user data
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateUser(userId, userData);
      await loadUsers(); // Refresh user list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteUser(userId);
      await loadUsers(); // Refresh user list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get user statistics
  Map<String, int> getUserStatistics() {
    final stats = <String, int>{};
    
    stats['total'] = _users.length;
    
    for (final role in UserRole.values) {
      stats[role.name] = _users.where((user) => user['role'] == role.name).length;
    }
    
    return stats;
  }

  // Get users by specific role
  List<Map<String, dynamic>> getUsersByRole(UserRole role) {
    return _users.where((user) => user['role'] == role.name).toList();
  }

  // Get recent users (created in last 7 days)
  List<Map<String, dynamic>> getRecentUsers() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return _users.where((user) {
      final createdAt = user['created_at'];
      if (createdAt is String) {
        final date = DateTime.parse(createdAt);
        return date.isAfter(weekAgo);
      }
      return false;
    }).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}