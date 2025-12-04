import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/screens/create_report_screen.dart';
import 'package:laporin/screens/admin_dashboard_screen.dart';
import 'package:badges/badges.dart' as badges;

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with role badge
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.white,
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Text(
                                          user.name[0].toUpperCase(),
                                          style: AppTextStyles.h2.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: badges.Badge(
                                    badgeContent: Icon(
                                      _getRoleIcon(user.role),
                                      color: AppColors.white,
                                      size: 12,
                                    ),
                                    badgeStyle: badges.BadgeStyle(
                                      badgeColor: _getRoleColor(user.role),
                                      padding: const EdgeInsets.all(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          user.name,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // User Email
                        Text(
                          user.email,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRoleIcon(user.role),
                                color: AppColors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.role.displayName,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // NIM/NIP
                        if (user.identifier != user.email)
                          Text(
                            user.identifier,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Menu Items
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: Icons.dashboard_rounded,
                title: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Profil Saya',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to profile screen
                },
              ),
              if (authProvider.canCreateReports())
                _buildMenuItem(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Buat Laporan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateReportScreen(),
                      ),
                    );
                  },
                ),
              _buildMenuItem(
                icon: Icons.assignment_outlined,
                title: 'Laporan Saya',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to my reports screen
                },
              ),
              if (authProvider.canManageReports())
                _buildMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                ),
              const Divider(height: 32),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings screen
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to help screen
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'Tentang',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to about screen
                },
              ),
              const Divider(height: 32),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context, authProvider);
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.user:
        return Icons.person_outline_rounded;
      case UserRole.mahasiswa:
        return Icons.school_rounded;
      case UserRole.dosen:
        return Icons.work_outline_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  Color _getRoleColor(UserRole role) {
    return role.color;
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Keluar',
              style: AppTextStyles.button,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
