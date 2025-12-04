import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/providers/user_management_provider.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/models/enums.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

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
    return Consumer2<UserManagementProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, child) {
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
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Management'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddUserDialog(context, userProvider),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => userProvider.loadUsers(),
              ),
            ],
          ),
          body: _buildBody(context, userProvider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserManagementProvider userProvider) {
    if (userProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (userProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
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

    return Column(
      children: [
        _buildStatisticsCard(userProvider),
        _buildSearchAndFilter(context, userProvider),
        Expanded(
          child: _buildUserList(context, userProvider),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(UserManagementProvider userProvider) {
    final stats = userProvider.getUserStatistics();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
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

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, UserManagementProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama, email, NIM, atau NIP...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: userProvider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => userProvider.searchUsers(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) => userProvider.searchUsers(value),
          ),
          const SizedBox(height: 12),
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilterChip('Semua', 'all', userProvider),
                _buildStatusFilterChip('User Terverifikasi', 'verified', userProvider),
                _buildStatusFilterChip('User Publik', 'public', userProvider),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, String status, UserManagementProvider userProvider) {
    final isSelected = userProvider.filterStatus == status;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => userProvider.filterByStatus(isSelected ? 'all' : status),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildUserList(BuildContext context, UserManagementProvider userProvider) {
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(context, user, userProvider);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, UserManagementProvider userProvider) {
    final role = UserRole.values.firstWhere(
      (r) => r.name == user['role'],
      orElse: () => UserRole.user,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: role.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: role.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      role.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: role.color,
                      ),
                    ),
                  ),
                ],
              ),
              if (user['nim'] != null || user['nip'] != null) ...[
                const SizedBox(height: 12),
                if (user['nim'] != null)
                  Row(
                    children: [
                      const Icon(Icons.school, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'NIM: ${user['nim']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (user['nip'] != null)
                  Row(
                    children: [
                      const Icon(Icons.badge, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'NIP: ${user['nip']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Role'),
                      onPressed: () => _showEditRoleDialog(context, user, userProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Data'),
                      onPressed: () => _showEditUserDialog(context, user, userProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _showDeleteUserDialog(context, user, userProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Icon(Icons.delete, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, UserManagementProvider userProvider) {
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
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
                          isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
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
                          nim: selectedRole == UserRole.mahasiswa ? nimController.text : null,
                          nip: selectedRole == UserRole.dosen ? nipController.text : null,
                          phone: phoneController.text.isNotEmpty ? phoneController.text : null,
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
                              content: Text(userProvider.errorMessage ?? 'Gagal membuat user'),
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

  void _showEditRoleDialog(BuildContext context, Map<String, dynamic> user, UserManagementProvider userProvider) {
    UserRole currentRole = UserRole.values.firstWhere(
      (r) => r.name == user['role'],
      orElse: () => UserRole.user,
    );
    UserRole selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Role - ${user['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${user['email']}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role Baru',
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: selectedRole == currentRole || userProvider.isLoading
                  ? null
                  : () async {
                      final success = await userProvider.updateUserRole(user['id'], selectedRole);

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Role berhasil diupdate!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(userProvider.errorMessage ?? 'Gagal mengupdate role'),
                            backgroundColor: AppColors.error,
                          ),
                        );
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
                  : const Text('Update Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user, UserManagementProvider userProvider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user['name']);
    final phoneController = TextEditingController(text: user['phone'] ?? '');
    final nimController = TextEditingController(text: user['nim'] ?? '');
    final nipController = TextEditingController(text: user['nip'] ?? '');

    final currentRole = UserRole.values.firstWhere(
      (r) => r.name == user['role'],
      orElse: () => UserRole.user,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Data - ${user['name']}'),
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
                if (currentRole == UserRole.mahasiswa)
                  TextFormField(
                    controller: nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (currentRole == UserRole.mahasiswa) {
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
                if (currentRole == UserRole.dosen)
                  TextFormField(
                    controller: nipController,
                    decoration: const InputDecoration(
                      labelText: 'NIP',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (currentRole == UserRole.dosen) {
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
                      final updateData = <String, dynamic>{
                        'name': nameController.text,
                        'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
                      };

                      if (currentRole == UserRole.mahasiswa) {
                        updateData['nim'] = nimController.text;
                      } else if (currentRole == UserRole.dosen) {
                        updateData['nip'] = nipController.text;
                      }

                      final success = await userProvider.updateUser(user['id'], updateData);

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data user berhasil diupdate!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(userProvider.errorMessage ?? 'Gagal mengupdate data user'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
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
                : const Text('Update Data'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, Map<String, dynamic> user, UserManagementProvider userProvider) {
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
                          content: Text(userProvider.errorMessage ?? 'Gagal menghapus user'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
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