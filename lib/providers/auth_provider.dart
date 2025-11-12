import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/models/enums.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.name;
  UserRole? get userRole => _currentUser?.role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isMahasiswa => _currentUser?.role == UserRole.mahasiswa;
  bool get isDosen => _currentUser?.role == UserRole.dosen;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      final roleStr = prefs.getString('user_role');

      if (userId != null && email != null && name != null && roleStr != null) {
        final role = UserRole.values.firstWhere(
          (e) => e.name == roleStr,
          orElse: () => UserRole.mahasiswa,
        );

        _currentUser = User(
          id: userId,
          name: name,
          email: email,
          role: role,
          nim: prefs.getString('user_nim'),
          nip: prefs.getString('user_nip'),
          phone: prefs.getString('user_phone'),
          avatarUrl: prefs.getString('user_avatar'),
          createdAt: DateTime.now(),
        );

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password, {UserRole? role}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual API call
      // For now, just validate email format and password length
      if (!_isValidEmail(email)) {
        _errorMessage = 'Email tidak valid';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password minimal 6 karakter';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user with role
      final userRole = role ?? UserRole.mahasiswa;
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      
      _currentUser = User(
        id: userId,
        name: email.split('@')[0],
        email: email,
        role: userRole,
        nim: userRole == UserRole.mahasiswa ? '2341720$userId'.substring(0, 10) : null,
        nip: userRole == UserRole.dosen ? '198${userId.substring(0, 10)}' : null,
        createdAt: DateTime.now(),
      );

      // Save user data
      await _saveUserData(_currentUser!);

      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login gagal. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(
    String name,
    String email,
    String password,
    UserRole role, {
    String? nim,
    String? nip,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Validate inputs
      if (name.isEmpty) {
        _errorMessage = 'Nama tidak boleh kosong';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _errorMessage = 'Email tidak valid';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password minimal 6 karakter';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate NIM for Mahasiswa
      if (role == UserRole.mahasiswa && (nim == null || nim.isEmpty)) {
        _errorMessage = 'NIM harus diisi untuk mahasiswa';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate NIP for Dosen
      if (role == UserRole.dosen && (nip == null || nip.isEmpty)) {
        _errorMessage = 'NIP harus diisi untuk dosen';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        role: role,
        nim: nim,
        nip: nip,
        phone: phone,
        createdAt: DateTime.now(),
      );

      // Save user data
      await _saveUserData(_currentUser!);

      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registrasi gagal. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_role', user.role.name);
    if (user.nim != null) await prefs.setString('user_nim', user.nim!);
    if (user.nip != null) await prefs.setString('user_nip', user.nip!);
    if (user.phone != null) await prefs.setString('user_phone', user.phone!);
    if (user.avatarUrl != null) {
      await prefs.setString('user_avatar', user.avatarUrl!);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      await _saveUserData(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Update profil gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user has permission
  bool hasPermission(UserRole requiredRole) {
    if (_currentUser == null) return false;
    
    // Admin has all permissions
    if (_currentUser!.role == UserRole.admin) return true;
    
    // Check specific role
    return _currentUser!.role == requiredRole;
  }

  // Check if user can manage reports
  bool canManageReports() {
    return _currentUser?.role == UserRole.admin;
  }

  // Check if user can create reports
  bool canCreateReports() {
    return _currentUser != null;
  }
}
