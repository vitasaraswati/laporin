import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/report_model.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Report? _report;
  bool _isLoading = true;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    final reportProvider = context.read<ReportProvider>();
    final report = await reportProvider.fetchReportById(widget.reportId);
    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveReport() async {
    if (_report == null) return;

    final authProvider = context.read<AuthProvider>();
    final adminId = authProvider.currentUser?.id;

    if (adminId == null) return;

    final confirmed = await _showConfirmDialog(
      'Setujui Laporan',
      'Apakah Anda yakin ingin menyetujui laporan ini?',
    );

    if (!confirmed) return;

    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.approveReport(_report!.id, adminId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil disetujui'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadReport();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reportProvider.errorMessage ?? 'Gagal menyetujui laporan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectReport() async {
    if (_report == null) return;

    _noteController.clear();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tolak Laporan', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Berikan alasan penolakan:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan tidak boleh kosong'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context, _noteController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (note == null || note.isEmpty) return;

    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.rejectReport(_report!.id, note);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil ditolak'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadReport();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reportProvider.errorMessage ?? 'Gagal menolak laporan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(ReportStatus newStatus) async {
    if (_report == null) return;

    final confirmed = await _showConfirmDialog(
      'Ubah Status',
      'Ubah status laporan menjadi "${newStatus.displayName}"?',
    );

    if (!confirmed) return;

    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.updateReportStatus(_report!.id, newStatus);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diubah'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadReport();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reportProvider.errorMessage ?? 'Gagal mengubah status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.h3),
        content: Text(content, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showStatusOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubah Status Laporan', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              if (_report?.status == ReportStatus.approved)
                ListTile(
                  leading: const Icon(Icons.autorenew, color: AppColors.primary),
                  title: const Text('Mulai Proses'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(ReportStatus.inProgress);
                  },
                ),
              if (_report?.status == ReportStatus.inProgress)
                ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.success),
                  title: const Text('Selesaikan'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(ReportStatus.resolved);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.canManageReports();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Detail Laporan',
            style: AppTextStyles.h3.copyWith(color: AppColors.white),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_report == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Detail Laporan',
            style: AppTextStyles.h3.copyWith(color: AppColors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Laporan tidak ditemukan', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Laporan',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        actions: [
          if (isAdmin && _report!.status == ReportStatus.approved || 
              _report!.status == ReportStatus.inProgress)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showStatusOptions,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(_report!.status),
                    _getStatusColor(_report!.status).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _report!.category.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _report!.category.displayName,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            badges.Badge(
                              badgeContent: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  _report!.status.displayName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              badgeStyle: badges.BadgeStyle(
                                badgeColor: AppColors.white.withValues(alpha: 0.3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 16,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _report!.priority.displayName,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _report!.title,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dilaporkan ${_formatDate(_report!.createdAt)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // Description Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deskripsi', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text(
                    _report!.description,
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            const Divider(height: 1),

            // Reporter Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pelapor', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          _report!.reporter.name[0].toUpperCase(),
                          style: AppTextStyles.h3.copyWith(color: AppColors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _report!.reporter.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _report!.reporter.email,
                              style: AppTextStyles.caption,
                            ),
                            if (_report!.reporter.identifier != _report!.reporter.email)
                              Text(
                                _report!.reporter.identifier,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _report!.reporter.role.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _report!.reporter.role.displayName,
                          style: AppTextStyles.caption.copyWith(
                            color: _report!.reporter.role.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

            const Divider(height: 1),

            // Location Section
            if (_report!.location != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.error),
                        title: Text(
                          _report!.location!.displayText,
                          style: AppTextStyles.body,
                        ),
                        subtitle: Text(
                          'Lat: ${_report!.location!.latitude.toStringAsFixed(6)}, Lng: ${_report!.location!.longitude.toStringAsFixed(6)}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

            if (_report!.location != null) const Divider(height: 1),

            // Media Section
            if (_report!.media.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lampiran (${_report!.media.length})', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _report!.media.length,
                        itemBuilder: (context, index) {
                          final media = _report!.media[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(media.url),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: AppColors.greyLight,
                                    child: const Icon(
                                      Icons.image,
                                      size: 48,
                                      color: AppColors.greyDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

            if (_report!.media.isNotEmpty) const Divider(height: 1),

            // Status Timeline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timeline Status', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  _buildTimelineItem(
                    icon: Icons.add_circle,
                    title: 'Laporan Dibuat',
                    date: _report!.createdAt,
                    isActive: true,
                    isFirst: true,
                  ),
                  if (_report!.approvedAt != null)
                    _buildTimelineItem(
                      icon: Icons.check_circle,
                      title: 'Disetujui',
                      date: _report!.approvedAt!,
                      isActive: true,
                    ),
                  if (_report!.status == ReportStatus.inProgress)
                    _buildTimelineItem(
                      icon: Icons.autorenew,
                      title: 'Dalam Proses',
                      date: _report!.updatedAt,
                      isActive: true,
                    ),
                  if (_report!.resolvedAt != null)
                    _buildTimelineItem(
                      icon: Icons.task_alt,
                      title: 'Selesai',
                      date: _report!.resolvedAt!,
                      isActive: true,
                      isLast: true,
                    ),
                  if (_report!.status == ReportStatus.rejected)
                    _buildTimelineItem(
                      icon: Icons.cancel,
                      title: 'Ditolak',
                      date: _report!.updatedAt,
                      isActive: true,
                      isLast: true,
                      color: AppColors.error,
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

            // Admin Note
            if (_report!.adminNote != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catatan Admin', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Text(
                        _report!.adminNote!,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 300.ms),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: isAdmin && (_report!.canBeApproved || _report!.canBeRejected)
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyLight.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_report!.canBeRejected)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _rejectReport,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: Text(
                          'Tolak',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  if (_report!.canBeRejected && _report!.canBeApproved)
                    const SizedBox(width: 12),
                  if (_report!.canBeApproved)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _approveReport,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.success,
                        ),
                        child: Text('Setujui', style: AppTextStyles.button),
                      ),
                    ),
                ],
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 300.ms)
          : null,
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required DateTime date,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
    Color? color,
  }) {
    final itemColor = color ?? (isActive ? AppColors.primary : AppColors.greyLight);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: itemColor,
              ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? itemColor : AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: itemColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(date),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
