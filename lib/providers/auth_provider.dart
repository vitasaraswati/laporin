import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/services/firebase_auth_service.dart';
import 'package:laporin/services/firestore_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useFirebase = false; // Toggle between Firebase and mock auth

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
  bool get isUser => _currentUser?.role == UserRole.user;
  
  // Check if user has admin-level permissions
  bool get hasAdminPermissions => isAdmin || isDosen;

  AuthProvider() {
    _useFirebase = true; // Enable Firebase by default
    _checkAuthStatus();
    _initializeFirebaseListener();
  }

  // Initialize Firebase auth state listener
  void _initializeFirebaseListener() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (_useFirebase && firebaseUser != null) {
        // Get user data from Firebase
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
          await _saveUserData(user);
          notifyListeners();
        }
      } else if (_useFirebase && firebaseUser == null) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  // Enable or disable Firebase authentication
  void setUseFirebase(bool value) {
    _useFirebase = value;
    notifyListeners();
  }

  bool get useFirebase => _useFirebase;

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _useFirebase = prefs.getBool('use_firebase') ?? false;

      if (_useFirebase) {
        // Check Firebase auth status
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        // Check local storage for mock auth
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
      if (_useFirebase) {
        // Use Firebase authentication
        final user = await _authService.signInWithEmailAndPassword(email, password);

        if (user != null) {
          _currentUser = user;
          await _saveUserData(user);
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Login gagal';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Use mock authentication
        await Future.delayed(const Duration(seconds: 2));

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

        // Mock users for testing
        User? mockUser = _getMockUser(email, password);

        if (mockUser != null) {
          _currentUser = mockUser;
          await _saveUserData(_currentUser!);
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        }

        // If not mock user, validate and create dynamic user
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

        await _saveUserData(_currentUser!);

        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
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
      if (_useFirebase) {
        // Use Firebase authentication
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
          _currentUser = user;
          await _saveUserData(user);
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Registrasi gagal';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Use mock authentication
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
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    await prefs.setBool('use_firebase', _useFirebase);
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
      if (_useFirebase) {
        // Update in Firebase
        await _authService.updateUserProfile(
          userId: _currentUser!.id,
          name: name,
          phone: phone,
          avatarUrl: avatarUrl,
        );
      }

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
      if (_useFirebase) {
        await _authService.signOut();
      }

      final prefs = await SharedPreferences.getInstance();
      // Only remove auth-related keys, preserve onboarding status
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      await prefs.remove('user_nim');
      await prefs.remove('user_nip');
      await prefs.remove('user_phone');
      await prefs.remove('user_avatar');
      await prefs.remove('use_firebase');

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

  // Get mock user for testing
  User? _getMockUser(String email, String password) {
    // Mock Admin Account
    if (email == 'admin@laporin.com' && password == 'admin123') {
      return User(
        id: 'admin001',
        name: 'Admin Laporin',
        email: 'admin@laporin.com',
        role: UserRole.admin,
        nip: '198501012010011001',
        phone: '081234567890',
        createdAt: DateTime(2024, 1, 1),
      );
    }

    // Mock Mahasiswa Account
    if (email == 'mahasiswa@student.polinema.ac.id' && password == 'mahasiswa123') {
      return User(
        id: 'mhs001',
        name: 'Budi Santoso',
        email: 'mahasiswa@student.polinema.ac.id',
        role: UserRole.mahasiswa,
        nim: '2341720001',
        phone: '081234567891',
        createdAt: DateTime(2024, 9, 1),
      );
    }

    // Mock Dosen Account
    if (email == 'dosen@polinema.ac.id' && password == 'dosen123') {
      return User(
        id: 'dsn001',
        name: 'Dr. Siti Aminah',
        email: 'dosen@polinema.ac.id',
        role: UserRole.dosen,
        nip: '198203152006042001',
        phone: '081234567892',
        createdAt: DateTime(2024, 1, 1),
      );
    }

    // No mock user found
    return null;
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

  // Login User (Mahasiswa & Civitas Akademika) using Firebase Auth
  Future<bool> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Always use Firebase authentication for users
      final user = await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        // Ensure the user is not admin
        if (user.role == UserRole.admin) {
          _errorMessage = 'Akun admin tidak dapat login sebagai user';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _currentUser = user;
        await _saveUserData(user);
        _status = AuthStatus.authenticated;
        _useFirebase = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login gagal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with default role as User
  Future<bool> registerAsUser(
    String name,
    String email,
    String password, {
    String? phone,
  }) async {
    return await register(
      name,
      email,
      password,
      UserRole.user, // Default role
      phone: phone,
    );
  }

  // Register with email and password only (simplified)
  Future<bool> registerSimple(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use Firebase authentication
      final user = await _authService.registerSimple(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserData(user);
        _status = AuthStatus.authenticated;
        _useFirebase = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registrasi gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registrasi gagal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile with complete data
  Future<bool> completeProfile({
    required String name,
    required UserRole role,
    String? nim,
    String? nip,
    String? phone,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Update in Firebase
      if (_useFirebase) {
        await _authService.updateUserProfile(
          userId: _currentUser!.id,
          name: name,
          phone: phone,
        );

        // Update user document with role and identifiers
        await _firestoreService.updateUser(_currentUser!.id, {
          'name': name,
          'role': role.name,
          'nim': nim,
          'nip': nip,
          'phone': phone,
        });
      }

      _currentUser = _currentUser!.copyWith(
        name: name,
        role: role,
        nim: nim,
        nip: nip,
        phone: phone,
      );

      await _saveUserData(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Update profil gagal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login Admin using Firestore data (no Firebase Auth)
  Future<bool> loginAdmin(String identityNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Query Firestore for admin with matching identity number
      final admins = await _firestoreService.getAdminByIdentity(identityNumber);

      if (admins.isEmpty) {
        _errorMessage = 'Admin tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final admin = admins.first;

      // Verify password (stored in Firestore)
      // Note: In production, passwords should be hashed
      if (admin['password'] != password) {
        _errorMessage = 'Password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create User object from Firestore data
      DateTime createdAt;
      final createdAtValue = admin['created_at'];
      if (createdAtValue != null) {
        try {
          createdAt = (createdAtValue as dynamic).toDate();
        } catch (_) {
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }

      _currentUser = User(
        id: admin['id'],
        name: admin['name'] ?? 'Admin',
        email: admin['email'] ?? 'admin@laporin.com',
        role: UserRole.admin,
        nip: admin['nip'],
        phone: admin['phone'],
        avatarUrl: admin['avatar_url'],
        createdAt: createdAt,
      );

      await _saveUserData(_currentUser!);
      _status = AuthStatus.authenticated;
      _useFirebase = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback to mock admin for development
      if (identityNumber == 'ADM001' && password == 'admin123') {
        _currentUser = User(
          id: 'admin001',
          name: 'Admin Laporin',
          email: 'admin@laporin.com',
          role: UserRole.admin,
          nip: 'ADM001',
          phone: '081234567890',
          createdAt: DateTime.now(),
        );

        await _saveUserData(_currentUser!);
        _status = AuthStatus.authenticated;
        _useFirebase = false;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login admin gagal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
