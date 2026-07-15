// lib/core/utils/image_utils.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static const String imageFolderName = 'club_images';

  // Get the app's document directory for permanent storage
  static Future<Directory> getImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/$imageFolderName');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    return imageDir;
  }

  // Save a single image to permanent storage
  static Future<File> saveImagePermanently(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final imageDir = await getImageDirectory();

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName =
          'img_${timestamp}_${DateTime.now().microsecondsSinceEpoch}$extension';
      final newPath = path.join(imageDir.path, fileName);

      // Copy the file
      final newFile = await imageFile.copy(newPath);

      if (kDebugMode) {
        print('✅ Image saved permanently: ${newFile.path}');
      }

      return newFile;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving image permanently: $e');
      }
      rethrow;
    }
  }

  // Save multiple images
  static Future<List<File>> saveImagesPermanently(List<File> imageFiles) async {
    final List<File> savedFiles = [];

    for (var image in imageFiles) {
      try {
        final savedFile = await saveImagePermanently(image);
        savedFiles.add(savedFile);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to save image: ${image.path}, Error: $e');
        }
        // Continue with other images
      }
    }

    return savedFiles;
  }

  // Pick images from gallery
  static Future<List<File>> pickMultipleImages(BuildContext context) async {
    final List<File> savedImages = [];

    try {
      final picker = ImagePicker();
      final List<XFile> pickedImages = await picker.pickMultiImage();

      if (pickedImages.isEmpty) {
        return [];
      }

      // Show loading indicator
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      for (var xFile in pickedImages) {
        try {
          final tempFile = File(xFile.path);
          if (await tempFile.exists()) {
            final savedFile = await saveImagePermanently(tempFile);
            savedImages.add(savedFile);
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error processing image: $e');
          }
          // Continue with next image
        }
      }

      // Close loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      if (kDebugMode) {
        print('✅ ${savedImages.length} images saved successfully');
      }

      return savedImages;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking images: $e');
      }
      // Close loading dialog if still open
      // ignore: use_build_context_synchronously
      if (Navigator.canPop(context)) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
      throw Exception('Failed to pick images: ${e.toString()}');
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedImage == null) return null;

      final tempFile = File(pickedImage.path);
      if (!await tempFile.exists()) {
        throw Exception('Image file does not exist');
      }

      return await saveImagePermanently(tempFile);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking image from camera: $e');
      }
      throw Exception('Failed to take photo: ${e.toString()}');
    }
  }

  // Clean up old images (optional)
  static Future<void> cleanupOldImages(int daysOld) async {
    try {
      final imageDir = await getImageDirectory();
      final files = await imageDir.list().toList();
      final cutoffTime = DateTime.now().subtract(Duration(days: daysOld));

      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await file.delete();
            if (kDebugMode) {
              print('🗑️ Deleted old image: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cleaning up images: $e');
      }
    }
  }
}
