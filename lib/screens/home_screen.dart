import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/widgets/profile_drawer.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/screens/create_report_screen.dart';
import 'package:laporin/screens/report_list_screen.dart';
import 'package:laporin/screens/report_detail_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ReportListScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LaporJTI',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      drawer: const ProfileDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.greyLight.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.greyDark,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.dashboard_outlined, 0),
                activeIcon: _buildNavIcon(Icons.dashboard_rounded, 0, isActive: true),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.assignment_outlined, 1),
                activeIcon: _buildNavIcon(Icons.assignment_rounded, 1, isActive: true),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_outline_rounded, 2),
                activeIcon: _buildNavIcon(Icons.person_rounded, 2, isActive: true),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.canCreateReports()) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateReportScreen(),
                ),
              );
              
              if (result == true && context.mounted) {
                context.read<ReportProvider>().fetchReports();
              }
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Buat Laporan'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ).animate().scale(delay: 300.ms, duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isActive ? 8 : 0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: isActive ? 28 : 24,
      ),
    ).animate().scale(
          duration: 200.ms,
          curve: Curves.easeInOut,
        );
  }
}

// Dashboard Page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ReportProvider>(
      builder: (context, authProvider, reportProvider, _) {
        final user = authProvider.currentUser;
        final stats = reportProvider.getReportStats();

        return RefreshIndicator(
          onRefresh: () => reportProvider.fetchReports(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Selamat Datang,',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  user?.name ?? 'User',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Text(
                  'Statistik Laporan',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Laporan',
                      stats['total'].toString(),
                      Icons.assignment_rounded,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      'Menunggu',
                      stats['pending'].toString(),
                      Icons.pending_outlined,
                      AppColors.warning,
                    ),
                    _buildStatCard(
                      'Diproses',
                      stats['inProgress'].toString(),
                      Icons.autorenew_rounded,
                      AppColors.info,
                    ),
                    _buildStatCard(
                      'Selesai',
                      stats['resolved'].toString(),
                      Icons.check_circle_rounded,
                      AppColors.success,
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Recent Reports
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Laporan Terbaru',
                      style: AppTextStyles.h3,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportListScreen(),
                          ),
                        );
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                reportProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : reportProvider.reports.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reportProvider.reports.take(5).length,
                            itemBuilder: (context, index) {
                              final report = reportProvider.reports[index];
                              return _buildReportCard(context, report, index);
                            },
                          ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), AppColors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(color: color),
                ),
                Text(
                  title,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, report, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: report.category.displayName == 'Kerusakan'
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              report.category.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          report.title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report.description,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            badges.Badge(
              badgeContent: Text(
                report.status.displayName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontSize: 10,
                ),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: _getStatusColor(report.status),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportId: report.id),
            ),
          );
        },
      ),
    ).animate(delay: (index * 100).ms).fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada laporan',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat laporan pertama Anda',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.warning;
      case ReportStatus.approved:
        return AppColors.info;
      case ReportStatus.inProgress:
        return AppColors.primary;
      case ReportStatus.resolved:
        return AppColors.success;
      case ReportStatus.rejected:
        return AppColors.error;
    }
  }
}

// Profile Page (placeholder)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Page - Coming Soon'),
    );
  }
}
