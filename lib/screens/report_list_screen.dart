import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/report_model.dart';
import 'package:laporin/screens/report_detail_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Laporan', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _filterStatus = null;
                            _filterCategory = null;
                          });
                          setState(() {
                            _filterStatus = null;
                            _filterCategory = null;
                          });
                          context.read<ReportProvider>().clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Filter
                  Text('Status', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        isSelected: _filterStatus == null,
                        onTap: () {
                          setModalState(() => _filterStatus = null);
                        },
                      ),
                      ...ReportStatus.values.map((status) {
                        return _buildFilterChip(
                          label: status.displayName,
                          isSelected: _filterStatus == status,
                          color: _getStatusColor(status),
                          onTap: () {
                            setModalState(() => _filterStatus = status);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Filter
                  Text('Kategori', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        isSelected: _filterCategory == null,
                        onTap: () {
                          setModalState(() => _filterCategory = null);
                        },
                      ),
                      ...ReportCategory.values.map((category) {
                        return _buildFilterChip(
                          label: '${category.icon} ${category.displayName}',
                          isSelected: _filterCategory == category,
                          onTap: () {
                            setModalState(() => _filterCategory = category);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        final provider = context.read<ReportProvider>();
                        provider.setStatusFilter(_filterStatus);
                        provider.setCategoryFilter(_filterCategory);
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withValues(alpha: 0.2)
              : AppColors.background,
          border: Border.all(
            color: isSelected ? (color ?? AppColors.primary) : AppColors.greyLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? (color ?? AppColors.primary) : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Semua Laporan',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: badges.Badge(
              showBadge: _filterStatus != null || _filterCategory != null,
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppColors.error,
                padding: EdgeInsets.all(4),
              ),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ReportProvider>().setSearchQuery(null);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
                context.read<ReportProvider>().setSearchQuery(value.isEmpty ? null : value);
              },
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Active Filters
          if (_filterStatus != null || _filterCategory != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.background,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_filterStatus != null)
                    Chip(
                      label: Text(_filterStatus!.displayName),
                      backgroundColor: _getStatusColor(_filterStatus!).withValues(alpha: 0.2),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => _filterStatus = null);
                        context.read<ReportProvider>().setStatusFilter(null);
                      },
                    ),
                  if (_filterCategory != null)
                    Chip(
                      label: Text('${_filterCategory!.icon} ${_filterCategory!.displayName}'),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() => _filterCategory = null);
                        context.read<ReportProvider>().setCategoryFilter(null);
                      },
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Report List
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, reportProvider, _) {
                if (reportProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (reportProvider.errorMessage != null) {
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
                        Text(
                          reportProvider.errorMessage!,
                          style: AppTextStyles.body.copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => reportProvider.fetchReports(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final reports = reportProvider.reports;

                if (reports.isEmpty) {
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
                          'Tidak ada laporan',
                          style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filterStatus != null || _filterCategory != null
                              ? 'Coba ubah filter'
                              : 'Belum ada laporan yang dibuat',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => reportProvider.fetchReports(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportCard(report, index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportId: report.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category Icon + Status Badge
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        report.category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.category.displayName,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  badges.Badge(
                    badgeContent: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        report.status.displayName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: _getStatusColor(report.status),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                report.description,
                style: AppTextStyles.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer: Reporter + Date + Priority
              Row(
                children: [
                  // Reporter
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      report.reporter.name[0].toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      report.reporter.name,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(report.priority).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      report.priority.displayName,
                      style: AppTextStyles.caption.copyWith(
                        color: _getPriorityColor(report.priority),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Date
                  Text(
                    _formatDate(report.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Location (if available)
              if (report.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location!.displayText,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Media count (if available)
              if (report.media.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.image, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${report.media.length} lampiran',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.inProgress:
        return AppColors.info;
      case ReportStatus.approved:
        return AppColors.success;
      case ReportStatus.rejected:
        return AppColors.error;
    }
  }

  Color _getPriorityColor(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return AppColors.success;
      case ReportPriority.medium:
        return AppColors.info;
      case ReportPriority.high:
        return AppColors.warning;
      case ReportPriority.urgent:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes}m lalu';
      }
      return '${difference.inHours}j lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
