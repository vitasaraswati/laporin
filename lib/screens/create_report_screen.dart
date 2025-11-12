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
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

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
  final List<XFile> _images = [];
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

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
          _images.addAll(selectedImages);
          if (_images.length > 5) {
            _images.removeRange(5, _images.length);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimal 5 gambar'),
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
          if (_images.length < 5) {
            _images.add(photo);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksimal 5 gambar'),
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

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
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
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.subLocality}, ${place.locality}';
        
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
      // Convert images to MediaFile objects
      final mediaFiles = _images
          .map((image) => MediaFile(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                url: image.path,
                type: MediaType.image,
                uploadedAt: DateTime.now(),
              ))
          .toList();

      final reportProvider = context.read<ReportProvider>();
      final success = await reportProvider.createReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        reporter: user,
        location: _location,
        media: mediaFiles,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil dibuat'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reportProvider.errorMessage ?? 'Gagal membuat laporan'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Laporan',
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
              DropdownButtonFormField<ReportPriority>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Prioritas',
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
              const SizedBox(height: 12),

              // Image Grid
              if (_images.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_images[index].path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(index),
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

              if (_images.isNotEmpty) const SizedBox(height: 12),

              // Image Picker Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _images.length >= 5 ? null : _takePhoto,
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
                      onPressed: _images.length >= 5 ? null : _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms, duration: 300.ms),

              if (_images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_images.length}/5 gambar',
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
                          'Kirim Laporan',
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
