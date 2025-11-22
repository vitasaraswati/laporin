import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/models/enums.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nimController;
  late TextEditingController _nipController;
  late TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isFirstTime = false;
  UserRole _selectedRole = UserRole.mahasiswa;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Check if this is first time setup (name is default "User")
    _isFirstTime = user?.name == 'User' || user?.name.isEmpty == true;
    _isEditing = _isFirstTime;
    _selectedRole = user?.role ?? UserRole.mahasiswa;

    _nameController = TextEditingController(text: user?.name == 'User' ? '' : user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _nimController = TextEditingController(text: user?.nim ?? '');
    _nipController = TextEditingController(text: user?.nip ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nimController.dispose();
    _nipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success;

      if (_isFirstTime) {
        // Complete profile for first time
        success = await authProvider.completeProfile(
          name: _nameController.text,
          role: _selectedRole,
          nim: _selectedRole == UserRole.mahasiswa ? _nimController.text : null,
          nip: _selectedRole == UserRole.dosen ? _nipController.text : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        );
      } else {
        // Update existing profile
        success = await authProvider.updateProfile(
          name: _nameController.text,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        );
      }

      if (mounted) {
        if (success) {
          setState(() {
            _isEditing = false;
            _isFirstTime = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to home after completing profile for first time
          if (_isFirstTime) {
            context.go('/home');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Gagal memperbarui profil'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isFirstTime ? 'Lengkapi Data Diri' : 'Profil Saya'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: _isFirstTime ? null : null, // Disable back button on first time
        actions: [
          if (!_isEditing && !_isFirstTime)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7)
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: user?.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.avatarUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                // TODO: Implement image picker
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Fitur ganti foto akan segera hadir'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.role.displayName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Pribadi', style: AppTextStyles.h3),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: _isEditing
                            ? Colors.white
                            : AppColors.background,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (Read-only)
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role Selection (only on first time)
                    if (_isFirstTime) ...[
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: _isEditing ? Colors.white : AppColors.background,
                        ),
                        items: [UserRole.mahasiswa, UserRole.dosen]
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.displayName),
                                ))
                            .toList(),
                        onChanged: _isEditing
                            ? (value) {
                                setState(() {
                                  _selectedRole = value!;
                                  _nimController.clear();
                                  _nipController.clear();
                                });
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // NIM (for Mahasiswa)
                    if (_selectedRole == UserRole.mahasiswa)
                      TextFormField(
                        controller: _nimController,
                        enabled: _isEditing && _isFirstTime,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'NIM',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: (_isEditing && _isFirstTime) ? Colors.white : AppColors.background,
                        ),
                        validator: _isFirstTime
                            ? (value) {
                                if (_selectedRole == UserRole.mahasiswa) {
                                  if (value == null || value.isEmpty) {
                                    return 'NIM tidak boleh kosong';
                                  }
                                  if (value.length != 10) {
                                    return 'NIM harus 10 digit';
                                  }
                                }
                                return null;
                              }
                            : null,
                      ),
                    if (_selectedRole == UserRole.dosen)
                      TextFormField(
                        controller: _nipController,
                        enabled: _isEditing && _isFirstTime,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'NIP',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: (_isEditing && _isFirstTime) ? Colors.white : AppColors.background,
                        ),
                        validator: _isFirstTime
                            ? (value) {
                                if (_selectedRole == UserRole.dosen) {
                                  if (value == null || value.isEmpty) {
                                    return 'NIP tidak boleh kosong';
                                  }
                                  if (value.length != 18) {
                                    return 'NIP harus 18 digit';
                                  }
                                }
                                return null;
                              }
                            : null,
                      ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: _isEditing
                            ? Colors.white
                            : AppColors.background,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    if (_isEditing)
                      Row(
                        children: [
                          if (!_isFirstTime)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    // Reset to original values
                                    _nameController.text = user?.name ?? '';
                                    _phoneController.text = user?.phone ?? '';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: AppColors.greyLight),
                                ),
                                child: const Text('Batal'),
                              ),
                            ),
                          if (!_isFirstTime) const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.primary,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isFirstTime ? 'Selesai' : 'Simpan',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
