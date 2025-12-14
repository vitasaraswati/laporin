import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/report_model.dart';
import 'package:laporin/screens/report_detail_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get user's reports
    final allUserReports = reportProvider.getReportsByUser(user.id);
    
    // Separate reports by status
    final diajukanReports = allUserReports
        .where((r) => r.status == ReportStatus.inProgress)
        .toList();
    final disetujuiReports = allUserReports
        .where((r) => r.status == ReportStatus.approved)
        .toList();
    final ditolakReports = allUserReports
        .where((r) => r.status == ReportStatus.rejected)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Saya'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              text: 'Semua (${allUserReports.length})',
              icon: const Icon(Icons.list_alt, size: 20),
            ),
            Tab(
              text: 'Diajukan (${diajukanReports.length})',
              icon: const Icon(Icons.pending_outlined, size: 20),
            ),
            Tab(
              text: 'Disetujui (${disetujuiReports.length})',
              icon: const Icon(Icons.check_circle_outline, size: 20),
            ),
            Tab(
              text: 'Ditolak (${ditolakReports.length})',
              icon: const Icon(Icons.cancel_outlined, size: 20),
            ),
          ],
        ),
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReportList(allUserReports, null),
                _buildReportList(diajukanReports, ReportStatus.inProgress),
                _buildReportList(disetujuiReports, ReportStatus.approved),
                _buildReportList(ditolakReports, ReportStatus.rejected),
              ],
            ),
    );
  }

  Widget _buildReportList(List<Report> reports, ReportStatus? status) {
    if (reports.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        final reportProvider = Provider.of<ReportProvider>(context, listen: false);
        await reportProvider.fetchReports();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildSimpleReportCard(report);
        },
      ),
    );
  }

  Widget _buildEmptyState(ReportStatus? status) {
    String message;
    IconData icon;

    if (status == null) {
      message = 'Belum ada laporan';
      icon = Icons.list_alt;
    } else {
      switch (status) {
        case ReportStatus.inProgress:
          message = 'Tidak ada laporan yang diajukan';
          icon = Icons.pending_outlined;
          break;
        case ReportStatus.approved:
          message = 'Tidak ada laporan yang disetujui';
          icon = Icons.check_circle_outline;
          break;
        case ReportStatus.rejected:
          message = 'Tidak ada laporan yang ditolak';
          icon = Icons.cancel_outlined;
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan yang Anda buat akan muncul di sini',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Simplified card: only title, status, and category
  Widget _buildSimpleReportCard(Report report) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(reportId: report.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(report.status),
              ],
            ),
            const SizedBox(height: 12),
            
            // Category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: report.category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: report.category.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        report.category.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.category.displayName,
                        style: AppTextStyles.body.copyWith(
                          color: report.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Date
                Text(
                  DateFormat('dd MMM yyyy').format(report.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
