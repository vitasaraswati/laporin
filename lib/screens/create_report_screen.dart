import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/report_provider.dart';
import 'package:laporin/models/enums.dart';
import 'package:laporin/models/location_model.dart';
import 'package:laporin/models/media_model.dart';
import 'package:laporin/models/report_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

// Helper class to store media with type
class MediaItem {
  final XFile file;
  final MediaType type;

  MediaItem({required this.file, required this.type});
}

class CreateReportScreen extends StatefulWidget {
  final Report? reportToEdit;

  const CreateReportScreen({super.key, this.reportToEdit});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReportCategory _selectedCategory = ReportCategory.kerusakan;
  ReportPriority _selectedPriority = ReportPriority.medium;
  LocationData? _location;
  final List<MediaItem> _mediaItems = [];
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  int get _imageCount => _mediaItems.where((m) => m.type == MediaType.image).length;
  int get _videoCount => _mediaItems.where((m) => m.type == MediaType.video).length;

  @override
  void initState() {
    super.initState();
    _initializeFormForEdit();
  }

  void _initializeFormForEdit() {
    if (widget.reportToEdit != null) {
      _titleController.text = widget.reportToEdit!.title;
      _descriptionController.text = widget.reportToEdit!.description;
      _selectedCategory = widget.reportToEdit!.category;
      _selectedPriority = widget.reportToEdit!.priority;
      _location = widget.reportToEdit!.location;
      // Note: Images dari report tidak bisa diedit untuk sederhananya
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage();

      if (selectedImages.isNotEmpty) {
        setState(() {
          for (var image in selectedImages) {
            if (_mediaItems.length < 5) {
              _mediaItems.add(MediaItem(file: image, type: MediaType.image));
            }
          }
          if (_mediaItems.length >= 5) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimal 5 lampiran'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih gambar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          if (_mediaItems.length < 5) {
            _mediaItems.add(MediaItem(file: photo, type: MediaType.image));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimal 5 lampiran'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil foto'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        setState(() {
          if (_mediaItems.length < 5) {
            _mediaItems.add(MediaItem(file: video, type: MediaType.video));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimal 5 lampiran'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih video'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        setState(() {
          if (_mediaItems.length < 5) {
            _mediaItems.add(MediaItem(file: video, type: MediaType.video));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimal 5 lampiran'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal merekam video'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaItems.removeAt(index);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get address from coordinates
      String address = 'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Build address with null safety
          final List<String> addressParts = [];
          if (place.street != null && place.street!.isNotEmpty) {
            addressParts.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          
          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
          }
        }
      } catch (e) {
        // If geocoding fails, use coordinates as address
        debugPrint('Geocoding error: $e');
      }
      
      setState(() {
        _location = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil didapatkan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reportProvider = context.read<ReportProvider>();
      bool success;

      // Check if this is edit mode or create mode
      if (widget.reportToEdit != null) {
        // Edit mode - update existing report
        success = await reportProvider.updateReport(
          widget.reportToEdit!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
        );
      } else {
        // Create mode - create new report
        // Convert media items to MediaFile objects
        final mediaFiles = _mediaItems
            .map((item) => MediaFile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  url: item.file.path,
                  type: item.type,
                  uploadedAt: DateTime.now(),
                ))
            .toList();

        success = await reportProvider.createReport(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          reporter: user,
          location: _location,
          media: mediaFiles,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.reportToEdit != null
                  ? 'Laporan berhasil diupdate'
                  : 'Laporan berhasil dibuat'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reportProvider.errorMessage ??
                  (widget.reportToEdit != null
                      ? 'Gagal mengupdate laporan'
                      : 'Gagal membuat laporan')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.reportToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Laporan' : 'Buat Laporan',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Text(
                'Informasi Laporan',
                style: AppTextStyles.h3,
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Laporan',
                  hintText: 'Contoh: Kursi rusak di ruang TI-201',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Judul minimal 10 karakter';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<ReportCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                items: ReportCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(category.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Priority Dropdown
              Text(
                'Prioritas Laporan',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Priority Guide Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Panduan Memilih Prioritas:',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPriorityGuide(
                      ReportPriority.low,
                      '🟢 Rendah',
                      'Mempengaruhi satu individu / masalah kosmetik',
                      'Contoh: 1 kursi rusak, cat mengelupas, lampu meja mati',
                    ),
                    const SizedBox(height: 6),
                    _buildPriorityGuide(
                      ReportPriority.medium,
                      '🟡 Sedang',
                      'Mempengaruhi satu kelompok kecil / kenyamanan umum satu ruangan',
                      'Contoh: AC bocor, WiFi lambat, toilet kotor',
                    ),
                    const SizedBox(height: 6),
                    _buildPriorityGuide(
                      ReportPriority.high,
                      '🔴 Tinggi',
                      'Mempengaruhi satu lokasi besar / banyak orang / proses vital / keamanan',
                      'Contoh: Listrik padam, kebocoran gas, server mati, proyektor di kelas yang sedang berlangsung',
                    ),
                    const SizedBox(height: 6),
                    
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<ReportPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Pilih Tingkat Prioritas',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: ReportPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan detail masalah yang Anda laporkan',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.trim().length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
              const SizedBox(height: 24),

              // Location Section
              Text(
                'Lokasi',
                style: AppTextStyles.h3,
              ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
              const SizedBox(height: 12),
              
              if (_location != null)
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: Text(
                      _location!.displayText,
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: Text(
                      'Lat: ${_location!.latitude.toStringAsFixed(6)}, Lng: ${_location!.longitude.toStringAsFixed(6)}',
                      style: AppTextStyles.caption,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _location = null;
                        });
                      },
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),

              ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLoadingLocation
                    ? 'Mengambil lokasi...'
                    : _location != null
                        ? 'Perbarui Lokasi'
                        : 'Ambil Lokasi Saat Ini'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 300.ms),
              const SizedBox(height: 24),

              // Media Section
              Text(
                'Lampiran (Opsional)',
                style: AppTextStyles.h3,
              ).animate().fadeIn(delay: 700.ms, duration: 300.ms),
              const SizedBox(height: 8),

              // Media count info
              if (_mediaItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      if (_imageCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '$_imageCount Foto',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_imageCount > 0 && _videoCount > 0) const SizedBox(width: 8),
                      if (_videoCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam, size: 14, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                '$_videoCount Video',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              // Media Grid
              if (_mediaItems.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _mediaItems.length,
                  itemBuilder: (context, index) {
                    final item = _mediaItems[index];
                    final isVideo = item.type == MediaType.video;

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isVideo
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black87,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 40,
                                      color: AppColors.white,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  File(item.file.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        // Video badge
                        if (isVideo)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'VIDEO',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ).animate().fadeIn(duration: 300.ms),

              if (_mediaItems.isNotEmpty) const SizedBox(height: 12),

              // Media Picker Buttons - Photos
              Text(
                'Foto',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _mediaItems.length >= 5 ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _mediaItems.length >= 5 ? null : _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms, duration: 300.ms),

              const SizedBox(height: 12),

              // Media Picker Buttons - Videos
              Text(
                'Video',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _mediaItems.length >= 5 ? null : _recordVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Rekam'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: _mediaItems.length >= 5 ? AppColors.greyLight : AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _mediaItems.length >= 5 ? null : _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: _mediaItems.length >= 5 ? AppColors.greyLight : AppColors.error),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 850.ms, duration: 300.ms),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_mediaItems.length}/5 lampiran (maks. video 2 menit)',
                  style: AppTextStyles.caption,
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Update Laporan' : 'Kirim Laporan',
                          style: AppTextStyles.button,
                        ),
                ),
              ).animate().fadeIn(delay: 900.ms, duration: 300.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityGuide(
    ReportPriority priority,
    String title,
    String description,
    String example,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                example,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
}
