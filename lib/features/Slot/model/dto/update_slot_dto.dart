import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class UpdateSlotDto {
  final String name;
  final double price;
  final bool isAvailable;
  final String? keptImageUrl;
  final File? newImage;

  UpdateSlotDto({
    required this.name,
    required this.price,
    required this.isAvailable,
    this.keptImageUrl,
    this.newImage,
  });

  // Check if this DTO requires multipart form data
  bool get hasFileUpload => newImage != null;

  // Convert to FormData for multipart upload (when sending a new image)
  Future<FormData> toFormData() async {
    MultipartFile? imageFile;

    if (newImage != null) {
      try {
        if (await newImage!.exists()) {
          final fileName = path.basename(newImage!.path);
          final fileSize = await newImage!.length();

          if (fileSize > 0) {
            imageFile = await MultipartFile.fromFile(
              newImage!.path,
              filename: fileName,
            );
          }
        }
      // ignore: empty_catches
      } catch (e) {
      }
    }

    final formData = FormData.fromMap({
      'name': name,
      'price': price.toString(),
      'is_available': isAvailable,
    });

    // Add kept image URL if provided
    if (keptImageUrl != null && keptImageUrl!.isNotEmpty) {
      formData.fields.add(MapEntry('kept_image_url', keptImageUrl!));
    }

    // Add new image if exists
    if (imageFile != null) {
      formData.files.add(MapEntry('image', imageFile));
    }

    return formData;
  }

  // Regular JSON conversion (without file)
  Map<String, dynamic> toJson() {
    final json = {'name': name, 'price': price, 'is_available': isAvailable};

    // Only add kept_image_url if it's not null and not empty
    if (keptImageUrl != null && keptImageUrl!.isNotEmpty) {
      json['kept_image_url'] = keptImageUrl as String;
    }

    return json;
  }

  UpdateSlotDto copyWith({
    String? name,
    double? price,
    bool? isAvailable,
    String? keptImageUrl,
    File? newImage,
  }) {
    return UpdateSlotDto(
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      keptImageUrl: keptImageUrl ?? this.keptImageUrl,
      newImage: newImage ?? this.newImage,
    );
  }
}
