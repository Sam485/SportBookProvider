import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class CreatedSportClubsDto {
  final String name;
  final double lat;
  final double lng;
  final String location;
  final bool isOpen;
  final Duration openTime;
  final Duration closeTime;
  final String description;
  final int categoryId;
  final List<File> images;

  CreatedSportClubsDto({
    required this.name,
    required this.lat,
    required this.lng,
    required this.location,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.description,
    required this.categoryId,
    required this.images,
  });

  // Convert to FormData for multipart upload
  Future<FormData> toFormData() async {
    List<MultipartFile> imageFiles = [];

    for (var image in images) {
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

    // Format duration
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours.remainder(24));
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    }

    final formData = FormData.fromMap({
      'name': name,
      'lat': lat.toString(),
      'lng': lng.toString(),
      'location': location,
      'is_open': isOpen,
      'open_time': formatDuration(openTime),
      'close_time': formatDuration(closeTime),
      'description': description,
      'category_id': categoryId,
    });

    // Add images if any exist
    if (imageFiles.isNotEmpty) {
      formData.files.addAll(imageFiles.map((file) => MapEntry('images', file)));
    } else {}

    return formData;
  }

  CreatedSportClubsDto copyWith({
    String? name,
    double? lat,
    double? lng,
    String? location,
    bool? isOpen,
    Duration? openTime,
    Duration? closeTime,
    String? description,
    int? categoryId,
    List<File>? images,
  }) {
    return CreatedSportClubsDto(
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
    );
  }
}
