import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/providers/user_management_provider.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/models/enums.dart';

class UserManagementScreen extends StatefulWidget {
  final bool showAppBar;
  const UserManagementScreen({super.key, this.showAppBar = true});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check admin permissions
        if (!authProvider.hasAdminPermissions) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('User Management'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Akses Ditolak',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Anda tidak memiliki izin untuk mengakses halaman ini',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Consumer<UserManagementProvider>(
          builder: (context, userProvider, child) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: widget.showAppBar
                  ? AppBar(
                      title: const Text('Admin Panel'),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    )
                  : null,
              body: _buildBody(context, userProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserManagementProvider userProvider) {
    if (userProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (userProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userProvider.errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                userProvider.clearError();
                userProvider.loadUsers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsGrid(userProvider),
          const SizedBox(height: 20),
          _buildAddUserAndFilterSection(context, userProvider),
          const SizedBox(height: 16),
          _buildSearchSection(context, userProvider),
          const SizedBox(height: 12),
          _buildUserList(context, userProvider),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(UserManagementProvider userProvider) {
    final stats = userProvider.getUserStatistics();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors
            .background, // Changed from Colors.white untuk testing hot reload
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik User',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total User',
                  stats['total']?.toString() ?? '0',
                  AppColors.primary,
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Admin',
                  stats['admin']?.toString() ?? '0',
                  AppColors.error,
                  Icons.admin_panel_settings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Terverifikasi',
                  _getVerifiedUsersCount(userProvider).toString(),
                  AppColors.success,
                  Icons.verified_user,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'User Publik',
                  _getPublicUsersCount(userProvider).toString(),
                  AppColors.primary,
                  Icons.public,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    UserManagementProvider userProvider,
  ) {
    final users = userProvider.filteredUsers;

    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada user ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba ubah filter atau kata kunci pencarian',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(context, user, userProvider);
      },
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Map<String, dynamic> user,
    UserManagementProvider userProvider,
  ) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == user['role'],
      orElse: () => UserRole.user,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: role.color.withOpacity(0.2),
                child: Text(
                  (user['name'] as String).substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: role.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user['email'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () =>
                        _showUserDetailDialog(context, user, userProvider),
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        _showDeleteUserDialog(context, user, userProvider),
                    icon: const Icon(Icons.delete, size: 16),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.error,
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddUserAndFilterSection(
    BuildContext context,
    UserManagementProvider userProvider,
  ) {
    return Row(
      children: [
        // Left side: Tambahkan User with + button
        Row(
          children: [
            const Text(
              'Tambahkan User',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                onPressed: () => _showAddUserDialog(context, userProvider),
              ),
            ),
          ],
        ),
        const Spacer(),
        // Right side: Filter dropdown
        Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: DropdownButton<String>(
            value: userProvider.currentFilter ?? 'all',
            underline: const SizedBox(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 16,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            focusColor: Colors.transparent,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Semua')),
              DropdownMenuItem(value: 'verified', child: Text('Terverifikasi')),
              DropdownMenuItem(value: 'public', child: Text('User Publik')),
            ],
            onChanged: (value) {
              if (value != null) {
                userProvider.filterByStatus(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(
    BuildContext context,
    UserManagementProvider userProvider,
  ) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari nama, email, NIM, atau NIP...',
        hintStyle: const TextStyle(fontSize: 14),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: userProvider.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => userProvider.searchUsers(''),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: (value) => userProvider.searchUsers(value),
    );
  }

  void _showAddUserDialog(
    BuildContext context,
    UserManagementProvider userProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final nimController = TextEditingController();
    final nipController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.user;
    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah User Baru'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value != passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              color: role.color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(role.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedRole == UserRole.mahasiswa)
                    TextFormField(
                      controller: nimController,
                      decoration: const InputDecoration(
                        labelText: 'NIM (untuk Civitas Mahasiswa)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (selectedRole == UserRole.mahasiswa) {
                          if (value == null || value.isEmpty) {
                            return 'NIM tidak boleh kosong';
                          }
                          if (value.length != 10) {
                            return 'NIM harus 10 digit';
                          }
                        }
                        return null;
                      },
                    ),
                  if (selectedRole == UserRole.dosen)
                    TextFormField(
                      controller: nipController,
                      decoration: const InputDecoration(
                        labelText: 'NIP *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (selectedRole == UserRole.dosen) {
                          if (value == null || value.isEmpty) {
                            return 'NIP tidak boleh kosong';
                          }
                          if (value.length != 18) {
                            return 'NIP harus 18 digit';
                          }
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon (Opsional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: userProvider.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        final success = await userProvider.createUser(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          role: selectedRole,
                          nim: selectedRole == UserRole.mahasiswa
                              ? nimController.text
                              : null,
                          nip: selectedRole == UserRole.dosen
                              ? nipController.text
                              : null,
                          phone: phoneController.text.isNotEmpty
                              ? phoneController.text
                              : null,
                        );

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User berhasil dibuat!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                userProvider.errorMessage ??
                                    'Gagal membuat user',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: userProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Buat User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailDialog(
    BuildContext context,
    Map<String, dynamic> user,
    UserManagementProvider userProvider,
  ) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == user['role'],
      orElse: () => UserRole.user,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: role.color.withOpacity(0.2),
              child: Text(
                (user['name'] as String).substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: role.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    role.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: role.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Email', user['email'] as String, Icons.email),
              if (user['nim'] != null && user['nim'].toString().isNotEmpty)
                _buildDetailRow('NIM', user['nim'] as String, Icons.school),
              if (user['nip'] != null && user['nip'].toString().isNotEmpty)
                _buildDetailRow('NIP', user['nip'] as String, Icons.badge),
              if (user['phone'] != null && user['phone'].toString().isNotEmpty)
                _buildDetailRow(
                  'Telepon',
                  user['phone'] as String,
                  Icons.phone,
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit User'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditUserDialog(context, user, userProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    Map<String, dynamic> user,
    UserManagementProvider userProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user['name']);
    final phoneController = TextEditingController(text: user['phone'] ?? '');
    final nimController = TextEditingController(text: user['nim'] ?? '');
    final nipController = TextEditingController(text: user['nip'] ?? '');

    UserRole currentRole = UserRole.values.firstWhere(
      (r) => r.name == user['role'],
      orElse: () => UserRole.user,
    );
    UserRole selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit User - ${user['name']}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              color: role.color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(role.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedRole == UserRole.mahasiswa)
                    TextFormField(
                      controller: nimController,
                      decoration: const InputDecoration(
                        labelText: 'NIM',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (selectedRole == UserRole.mahasiswa) {
                          if (value == null || value.isEmpty) {
                            return 'NIM tidak boleh kosong';
                          }
                          if (value.length != 10) {
                            return 'NIM harus 10 digit';
                          }
                        }
                        return null;
                      },
                    ),
                  if (selectedRole == UserRole.dosen)
                    TextFormField(
                      controller: nipController,
                      decoration: const InputDecoration(
                        labelText: 'NIP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (selectedRole == UserRole.dosen) {
                          if (value == null || value.isEmpty) {
                            return 'NIP tidak boleh kosong';
                          }
                          if (value.length != 18) {
                            return 'NIP harus 18 digit';
                          }
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: userProvider.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        bool success = true;

                        // Update role if changed
                        if (selectedRole != currentRole) {
                          success = await userProvider.updateUserRole(
                            user['id'],
                            selectedRole,
                          );
                        }

                        // Update user data if role update was successful
                        if (success) {
                          final updateData = <String, dynamic>{
                            'name': nameController.text,
                            'phone': phoneController.text.isNotEmpty
                                ? phoneController.text
                                : null,
                          };

                          if (selectedRole == UserRole.mahasiswa) {
                            updateData['nim'] = nimController.text;
                          } else if (selectedRole == UserRole.dosen) {
                            updateData['nip'] = nipController.text;
                          }

                          success = await userProvider.updateUser(
                            user['id'],
                            updateData,
                          );
                        }

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User berhasil diupdate!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                userProvider.errorMessage ??
                                    'Gagal mengupdate user',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: userProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(
    BuildContext context,
    Map<String, dynamic> user,
    UserManagementProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus user ini?'),
            const SizedBox(height: 12),
            Text('Nama: ${user['name']}'),
            Text('Email: ${user['email']}'),
            const SizedBox(height: 12),
            const Text(
              'Tindakan ini tidak dapat dibatalkan!',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: userProvider.isLoading
                ? null
                : () async {
                    final success = await userProvider.deleteUser(user['id']);

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User berhasil dihapus!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            userProvider.errorMessage ?? 'Gagal menghapus user',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: userProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  int _getVerifiedUsersCount(UserManagementProvider userProvider) {
    return userProvider.users.where((user) {
      return (user['nim'] != null && user['nim'].toString().isNotEmpty) ||
          (user['nip'] != null && user['nip'].toString().isNotEmpty);
    }).length;
  }

  int _getPublicUsersCount(UserManagementProvider userProvider) {
    return userProvider.users.where((user) {
      return (user['nim'] == null || user['nim'].toString().isEmpty) &&
          (user['nip'] == null || user['nip'].toString().isEmpty) &&
          user['role'] != 'admin';
    }).length;
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.dosen:
        return Icons.school;
      case UserRole.mahasiswa:
        return Icons.person;
      case UserRole.user:
        return Icons.person_outline;
    }
  }
}
