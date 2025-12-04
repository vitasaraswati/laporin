import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporin/models/report_model.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/models/enums.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== REPORTS ==========

  // Create a new report
  Future<String> createReport(Report report) async {
    try {
      final docRef = await _firestore.collection('reports').add(report.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Gagal membuat laporan: $e';
    }
  }

  // Get all reports
  Stream<List<Report>> getReports() {
    return _firestore
        .collection('reports')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromJson({
                  ...doc.data(),
                  'id': doc.id, // Set AFTER spread to ensure correct doc ID
                }))
            .toList());
  }

  // Get reports by user ID
  Stream<List<Report>> getReportsByUserId(String userId) {
    return _firestore
        .collection('reports')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get reports by status
  Stream<List<Report>> getReportsByStatus(ReportStatus status) {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: status.name)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Report.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get single report by ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      if (doc.exists) {
        return Report.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw 'Gagal mengambil laporan: $e';
    }
  }

  // Update report status (Admin only)
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status.name,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal memperbarui status laporan: $e';
    }
  }

  // Update report
  Future<void> updateReport(String reportId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('reports').doc(reportId).update(updates);
    } catch (e) {
      throw 'Gagal memperbarui laporan: $e';
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw 'Gagal menghapus laporan: $e';
    }
  }

  // Get report statistics
  Future<Map<String, int>> getReportStatistics() async {
    try {
      final snapshot = await _firestore.collection('reports').get();
      final reports = snapshot.docs
          .map((doc) => Report.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      return {
        'total': reports.length,
        'inProgress': reports.where((r) => r.status == ReportStatus.inProgress).length,
        'approved': reports.where((r) => r.status == ReportStatus.approved).length,
        'rejected': reports.where((r) => r.status == ReportStatus.rejected).length,
      };
    } catch (e) {
      throw 'Gagal mengambil statistik: $e';
    }
  }

  // ========== USERS ==========

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all users (Admin only)
  Stream<List<User>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get users by role
  Stream<List<User>> getUsersByRole(UserRole role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.name)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw 'Gagal memperbarui user: $e';
    }
  }

  // Search reports
  Future<List<Report>> searchReports(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation. For production, use Algolia or similar
      final snapshot = await _firestore.collection('reports').get();

      final reports = snapshot.docs
          .map((doc) => Report.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      return reports.where((report) {
        final titleMatch = report.title.toLowerCase().contains(query.toLowerCase());
        final descMatch = report.description.toLowerCase().contains(query.toLowerCase());
        final categoryMatch = report.category.displayName.toLowerCase().contains(query.toLowerCase());
        return titleMatch || descMatch || categoryMatch;
      }).toList();
    } catch (e) {
      throw 'Gagal mencari laporan: $e';
    }
  }

  // Get user report count
  Future<int> getUserReportCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('user_id', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Batch update reports
  Future<void> batchUpdateReports(
    List<String> reportIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      final batch = _firestore.batch();
      updates['updated_at'] = FieldValue.serverTimestamp();

      for (final id in reportIds) {
        batch.update(_firestore.collection('reports').doc(id), updates);
      }

      await batch.commit();
    } catch (e) {
      throw 'Gagal memperbarui laporan: $e';
    }
  }

  // ========== ADMIN ==========

  // Get admin by identity number (NIP)
  Future<List<Map<String, dynamic>>> getAdminByIdentity(String identityNumber) async {
    try {
      final snapshot = await _firestore
          .collection('admins')
          .where('nip', isEqualTo: identityNumber)
          .limit(1)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw 'Gagal mencari admin: $e';
    }
  }

  // Create admin account
  Future<String> createAdmin({
    required String name,
    required String nip,
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      final docRef = await _firestore.collection('admins').add({
        'name': name,
        'nip': nip,
        'password': password, // Note: Should be hashed in production
        'email': email,
        'phone': phone,
        'role': 'admin',
        'avatar_url': null,
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Gagal membuat admin: $e';
    }
  }

  // Get all users for user management (Admin only)
  Future<List<Map<String, dynamic>>> getAllUsersForManagement() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw 'Gagal mengambil data user: $e';
    }
  }

  // Create user (Admin only)
  Future<String> createUser(Map<String, dynamic> userData) async {
    try {
      userData['created_at'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection('users').add(userData);
      return docRef.id;
    } catch (e) {
      throw 'Gagal membuat user: $e';
    }
  }

  // Delete user (Admin only)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw 'Gagal menghapus user: $e';
    }
  }

  // Update user role (Admin only)
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Gagal mengupdate role user: $e';
    }
  }

  // Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      // Get all users first since Firestore doesn't support OR queries easily
      final snapshot = await _firestore
          .collection('users')
          .orderBy('created_at', descending: true)
          .get();

      final allUsers = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Filter locally
      final filteredUsers = allUsers.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || email.contains(searchQuery);
      }).toList();

      return filteredUsers;
    } catch (e) {
      throw 'Gagal mencari user: $e';
    }
  }
}
