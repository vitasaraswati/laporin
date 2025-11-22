import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/user_model.dart';
import 'package:laporin/screens/create_report_screen.dart';
import 'package:laporin/screens/report_list_screen.dart';
import 'package:laporin/screens/report_detail_screen.dart';
import 'package:laporin/screens/admin_dashboard_screen.dart';
import 'package:laporin/widgets/profile_drawer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PersistentTabController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentIndex = _controller.index;
        });
      }
    });
    // Load reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      const DashboardPage(),
      const ReportListScreen(),
      const ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_rounded, size: 26),
        title: "Beranda",
        activeColorPrimary: AppColors.primary,
        activeColorSecondary: AppColors.primary,
        inactiveColorPrimary: Colors.grey.shade500,
        inactiveColorSecondary: Colors.grey.shade500,
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.assignment_rounded, size: 26),
        title: "Laporan",
        activeColorPrimary: AppColors.primary,
        activeColorSecondary: AppColors.primary,
        inactiveColorPrimary: Colors.grey.shade500,
        inactiveColorSecondary: Colors.grey.shade500,
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_rounded, size: 26),
        title: "Profil",
        activeColorPrimary: AppColors.primary,
        activeColorSecondary: AppColors.primary,
        inactiveColorPrimary: Colors.grey.shade500,
        inactiveColorSecondary: Colors.grey.shade500,
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 400),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: 65,
      navBarStyle: NavBarStyle.style6,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      floatingActionButton: authProvider.canCreateReports() && _currentIndex == 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
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
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 24,
                    color: AppColors.white,
                  ),
                ),
                label: Text(
                  'Tambah Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 2500.ms,
                  color: AppColors.primary.withOpacity(0.2),
                )
                .scale(
                  duration: 1500.ms,
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.03, 1.03),
                  curve: Curves.easeInOut,
                ),
            )
          : null,
    );
  }
}

// Dashboard Page
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ReportProvider>(
      builder: (context, authProvider, reportProvider, _) {
        final user = authProvider.currentUser;
        final stats = reportProvider.getReportStats();

        // Filter reports based on selected status
        final filteredReports = _selectedFilter == 'Semua'
            ? reportProvider.reports
            : reportProvider.reports.where((report) {
                if (_selectedFilter == 'Diajukan') {
                  return report.status == ReportStatus.inProgress;
                } else if (_selectedFilter == 'Disetujui') {
                  return report.status == ReportStatus.approved;
                } else if (_selectedFilter == 'Ditolak') {
                  return report.status == ReportStatus.rejected;
                }
                return true;
              }).toList();

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.report_problem_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2200.ms, color: AppColors.white.withOpacity(0.6))
                  .scale(
                    duration: 1800.ms,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.08, 1.08),
                    curve: Curves.easeInOut,
                  ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LaporJTI',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Sistem Pelaporan',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withOpacity(0.95),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.3, end: 0),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.white,
                        size: 23,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.error,
                            AppColors.error.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 1200.ms,
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.15, 1.15),
                        curve: Curves.easeInOut,
                      )
                      .shimmer(
                        duration: 2000.ms,
                        color: AppColors.white.withOpacity(0.6),
                      ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: const ProfileDrawer(),
          body: RefreshIndicator(
            onRefresh: () => reportProvider.fetchReports(),
            color: AppColors.primary,
            backgroundColor: AppColors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Welcome Section - Simple & Clean
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang! 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'User',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              user?.role == UserRole.admin
                                  ? Icons.admin_panel_settings
                                  : user?.role == UserRole.dosen
                                      ? Icons.school
                                      : Icons.person,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user?.role.displayName ?? 'User',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms)
                      .scale(curve: Curves.elasticOut)
                      .shimmer(duration: 2000.ms, delay: 400.ms, color: Colors.white.withOpacity(0.5)),
                  ],
                ),
                const SizedBox(height: 28),

                // Quick Access for Admin - Modern Gradient Design
                if (authProvider.canManageReports()) ...[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.white.withOpacity(0.3),
                                  AppColors.white.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: AppColors.white,
                              size: 36,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Dashboard',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Kelola dan approve laporan masuk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .moveX(duration: 1000.ms, begin: 0, end: 4),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart)
                    .shimmer(duration: 2000.ms, delay: 500.ms, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 28),
                ],

                // Statistics Cards - Clean & Simple
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistik Laporan',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                const SizedBox(height: 20),
                
                // Statistics Grid - Proper Sizing
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildCleanStatCard(
                      'Total Laporan',
                      stats['total'].toString(),
                      Icons.assignment_rounded,
                      AppColors.primary,
                      0,
                    ),
                    _buildCleanStatCard(
                      'Diajukan',
                      stats['inProgress'].toString(),
                      Icons.schedule_rounded,
                      AppColors.warning,
                      1,
                    ),
                    _buildCleanStatCard(
                      'Disetujui',
                      stats['approved'].toString(),
                      Icons.check_circle_rounded,
                      AppColors.success,
                      2,
                    ),
                    _buildCleanStatCard(
                      'Ditolak',
                      stats['rejected'].toString(),
                      Icons.cancel_rounded,
                      AppColors.error,
                      3,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Recent Reports with Modern Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Terbaru',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update terkini dari sistem',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        'Lihat Semua',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 16),
                
                // Filter Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', Icons.all_inclusive),
                      const SizedBox(width: 10),
                      _buildFilterChip('Diajukan', Icons.schedule_rounded),
                      const SizedBox(width: 10),
                      _buildFilterChip('Disetujui', Icons.check_circle_rounded),
                      const SizedBox(width: 10),
                      _buildFilterChip('Ditolak', Icons.cancel_rounded),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                const SizedBox(height: 20),
                
                reportProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredReports.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredReports.take(5).length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return _buildReportCard(context, report, index);
                            },
                          ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    Color chipColor;

    switch (label) {
      case 'Diajukan':
        chipColor = AppColors.warning;
        break;
      case 'Disetujui':
        chipColor = AppColors.success;
        break;
      case 'Ditolak':
        chipColor = AppColors.error;
        break;
      default:
        chipColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : chipColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.white : chipColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scale(duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildCleanStatCard(String title, String value, IconData icon, Color color, int index) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.12),
              color.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart)
      .shimmer(duration: 1800.ms, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildReportCard(BuildContext context, report, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final canModify = report.status.canBeModified &&
                      currentUser != null &&
                      report.reporter.id == currentUser.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: _getStatusColor(report.status).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportId: report.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white,
                _getStatusColor(report.status).withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor(report.status).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatusColor(report.status).withOpacity(0.15),
                          _getStatusColor(report.status).withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        report.category.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report.description,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getStatusColor(report.status),
                                    _getStatusColor(report.status)
                                        .withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                report.status.displayName,
                                style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.greyLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPriorityIcon(report.priority),
                                    size: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    report.priority.displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu Button for edit/delete (only if can modify)
                  if (canModify)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateReportScreen(reportToEdit: report),
                            ),
                          );
                          if (result == true && context.mounted) {
                            reportProvider.fetchReports();
                          }
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, report, reportProvider);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Edit Laporan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Hapus Laporan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                ],
              ),
              // Info text for modifiable reports
              if (canModify) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Anda dapat mengedit atau menghapus laporan ini',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }

  void _showDeleteConfirmation(
      BuildContext context, report, ReportProvider reportProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Laporan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus laporan ini?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text(report.category.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await reportProvider.deleteReport(report.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Laporan berhasil dihapus'
                          : 'Gagal menghapus laporan',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada laporan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat laporan pertama Anda sekarang!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  IconData _getPriorityIcon(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return Icons.arrow_downward_rounded;
      case ReportPriority.medium:
        return Icons.remove_rounded;
      case ReportPriority.high:
        return Icons.arrow_upward_rounded;
      case ReportPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.inProgress:
        return AppColors.warning;
      case ReportStatus.approved:
        return AppColors.success;
      case ReportStatus.rejected:
        return AppColors.error;
    }
  }
}

// Profile Page (placeholder)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
          // App Bar dengan Gradient
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ).animate().scale(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    // Name
                    Text(
                      user.name,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 4),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Info Cards
                _buildInfoSection(user),

                const SizedBox(height: 16),

                // Statistics
                _buildStatisticsSection(user),

                const SizedBox(height: 16),

                // Menu Items
                _buildMenuSection(context, authProvider),

                const SizedBox(height: 20),

                // Logout Button
                _buildLogoutButton(context, authProvider),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Akun',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.email_rounded,
            title: 'Email',
            value: user.email,
            color: AppColors.info,
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 12),
          if (user.nim != null)
            _buildInfoCard(
              icon: Icons.badge_rounded,
              title: user.role == UserRole.mahasiswa ? 'NIM' : 'NIP',
              value: user.nim!,
              color: AppColors.success,
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideX(begin: -0.2, end: 0),
          if (user.nim != null) const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.calendar_today_rounded,
            title: 'Bergabung Sejak',
            value: DateFormat('dd MMMM yyyy').format(user.createdAt),
            color: AppColors.warning,
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyLight.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(User user) {
    final reportProvider = context.watch<ReportProvider>();
    
    // Filter reports by current user
    final userReports = reportProvider.reports
        .where((r) => r.reporter.id == user.id)
        .toList();
    
    final userInProgress = userReports
        .where((r) => r.status == ReportStatus.inProgress)
        .length;
    final userApproved = userReports
        .where((r) => r.status == ReportStatus.approved)
        .length;
    final userRejected = userReports
        .where((r) => r.status == ReportStatus.rejected)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Laporan Saya',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_rounded,
                  label: 'Total',
                  value: userReports.length.toString(),
                  color: AppColors.primary,
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms).scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule_rounded,
                  label: 'Diajukan',
                  value: userInProgress.toString(),
                  color: AppColors.warning,
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms).scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Disetujui',
                  value: userApproved.toString(),
                  color: AppColors.success,
                ).animate().fadeIn(delay: 300.ms, duration: 300.ms).scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cancel_rounded,
                  label: 'Ditolak',
                  value: userRejected.toString(),
                  color: AppColors.error,
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms).scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'Riwayat Laporan',
            subtitle: 'Lihat semua laporan yang pernah dibuat',
            color: AppColors.info,
            onTap: () {
              // Navigate to report history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera hadir'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.notifications_rounded,
            title: 'Notifikasi',
            subtitle: 'Atur preferensi notifikasi',
            color: AppColors.warning,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera hadir'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideX(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.help_rounded,
            title: 'Bantuan & FAQ',
            subtitle: 'Panduan penggunaan aplikasi',
            color: AppColors.success,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera hadir'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideX(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.info_rounded,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            color: AppColors.primary,
            onTap: () {
              _showAboutDialog(context);
            },
          ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyLight.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context, authProvider),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar dari Akun'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.error, width: 2),
            foregroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Keluar dari Akun'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_rounded,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Tentang Aplikasi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laporin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versi 1.0.0',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            Text(
              'Aplikasi pelaporan masalah kampus untuk memudahkan mahasiswa, dosen, dan staff dalam melaporkan dan mengelola berbagai permasalahan infrastruktur kampus.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Politeknik Negeri Malang',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.copyright_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '2025 Laporin Team',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
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
}
