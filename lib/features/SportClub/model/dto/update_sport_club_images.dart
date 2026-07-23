import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class UpdateSportClubImages {
  final String name;
  final bool isOpen;
  final bool imagesChanged;
  final List<String> keptImageUrls;
  final List<File>? images;

  UpdateSportClubImages({
    required this.name,
    required this.isOpen,
    required this.imagesChanged,
    required this.keptImageUrls,
    required this.images,
  });

  Future<FormData> toFormData() async {
    List<MultipartFile> imageFiles = [];

    for (var image in images!) {
      try {
        // Check if file exists
        if (await image.exists()) {
          final fileName = path.basename(image.path);
          final fileSize = await image.length();

          if (fileSize > 0) {
            imageFiles.add(
              await MultipartFile.fromFile(image.path, filename: fileName),
            );
          } else {}
        } else {}
        // ignore: empty_catches
      } catch (e) {}
    }

    final formData = FormData.fromMap({
      'name': name,
      'isOpen': isOpen,
      'imagesChanged': imagesChanged,
      'keptImageUrls': keptImageUrls,
    });

    // Add images if any exist
    if (imageFiles.isNotEmpty) {
      formData.files.addAll(imageFiles.map((file) => MapEntry('images', file)));
    } else {}

    return formData;
  }

  UpdateSportClubImages copyWith({
    String? name,
    bool? isOpen,
    bool? imagesChanged,
    List<String>? keptImageUrls,
    List<File>? images,
  }) {
    return UpdateSportClubImages(
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      imagesChanged: imagesChanged ?? this.imagesChanged,
      keptImageUrls: keptImageUrls ?? this.keptImageUrls,
      images: images ?? this.images,
    );
  }
}
