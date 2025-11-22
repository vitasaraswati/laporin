import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image and return download URL
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    required String folder, // 'avatars', 'reports', etc.
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$folder/$userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_by': userId,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Gagal mengupload gambar: $e';
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<XFile> imageFiles,
    required String userId,
    required String folder,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final urls = <String>[];
      int current = 0;

      for (final imageFile in imageFiles) {
        current++;
        onProgress?.call(current, imageFiles.length);

        final url = await uploadImage(
          imageFile: File(imageFile.path),
          userId: userId,
          folder: folder,
        );
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw 'Gagal mengupload gambar: $e';
    }
  }

  // Upload video and return download URL
  Future<String> uploadVideo({
    required File videoFile,
    required String userId,
    required String folder,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(videoFile.path)}';
      final ref = _storage.ref().child('$folder/$userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'uploaded_by': userId,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Gagal mengupload video: $e';
    }
  }

  // Delete file by URL
  Future<void> deleteFileByUrl(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw 'Gagal menghapus file: $e';
    }
  }

  // Delete multiple files by URLs
  Future<void> deleteMultipleFiles(List<String> fileUrls) async {
    try {
      for (final url in fileUrls) {
        await deleteFileByUrl(url);
      }
    } catch (e) {
      throw 'Gagal menghapus file: $e';
    }
  }

  // Delete all files in a folder
  Future<void> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }

      // Recursively delete subfolders
      for (final prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      throw 'Gagal menghapus folder: $e';
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Gagal mengambil metadata: $e';
    }
  }

  // Upload with progress tracking
  Future<String> uploadImageWithProgress({
    required File imageFile,
    required String userId,
    required String folder,
    required Function(double progress) onProgress,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$folder/$userId/$fileName');

      final uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Gagal mengupload gambar: $e';
    }
  }

  // Get all files in a folder
  Future<List<String>> getFilesInFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();

      final urls = <String>[];
      for (final item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw 'Gagal mengambil file: $e';
    }
  }

  // Get storage usage for a user
  Future<int> getUserStorageUsage(String userId) async {
    try {
      int totalSize = 0;
      final folders = ['avatars', 'reports'];

      for (final folder in folders) {
        final ref = _storage.ref().child('$folder/$userId');
        try {
          final listResult = await ref.listAll();

          for (final item in listResult.items) {
            final metadata = await item.getMetadata();
            totalSize += metadata.size ?? 0;
          }
        } catch (e) {
          // Folder might not exist, continue
          continue;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // Compress and upload image
  Future<String> compressAndUploadImage({
    required File imageFile,
    required String userId,
    required String folder,
    int quality = 85,
  }) async {
    try {
      // Note: You might want to use image_compression package for actual compression
      // For now, we'll just upload the image as is
      return await uploadImage(
        imageFile: imageFile,
        userId: userId,
        folder: folder,
      );
    } catch (e) {
      throw 'Gagal mengupload gambar: $e';
    }
  }
}
