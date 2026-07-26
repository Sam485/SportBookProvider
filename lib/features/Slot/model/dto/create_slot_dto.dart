import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class CreateSlotDto {
  final int sportClubId;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final bool isAvailable;
  final int categoryId;
  final File image;

  CreateSlotDto({
    required this.sportClubId,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.isAvailable,
    required this.categoryId,
    required this.image,
  });

  // Convert to FormData for multipart upload
  Future<FormData> toFormData() async {
    MultipartFile? imageFile;

    try {
      // Check if file exists
      if (await image.exists()) {
        final fileName = path.basename(image.path);
        final fileSize = await image.length();

        if (fileSize > 0) {
          imageFile = await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          );
        }
      }
    // ignore: empty_catches
    } catch (e) {
    }

    return FormData.fromMap({
      'sport_club_id': sportClubId,
      'name': name,
      'description': description,
      'price': price.toString(),
      'capacity': capacity,
      'is_available': isAvailable,
      'category_id': categoryId,
      'image': imageFile, // This will be handled as multipart file
    });
  }

  // Regular JSON conversion (if needed for non-file operations)
  Map<String, dynamic> toJson() {
    return {
      'sport_club_id': sportClubId,
      'name': name,
      'description': description,
      'price': price,
      'capacity': capacity,
      'is_available': isAvailable,
      'category_id': categoryId,
    };
  }

  CreateSlotDto copyWith({
    int? sportClubId,
    String? name,
    String? description,
    double? price,
    int? capacity,
    bool? isAvailable,
    int? categoryId,
    File? image,
  }) {
    return CreateSlotDto(
      sportClubId: sportClubId ?? this.sportClubId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
    );
  }
}
