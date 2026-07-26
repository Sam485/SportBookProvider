import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class UpdateSportClubDto {
  final String name;
  final String location;
  final String description;
  final Duration openTime;
  final Duration closeTime;
  final double lat;
  final double lng;
  final bool isOpen;
  final int categoryId;
  final List<File>? images;
  final List<String>? keptImageUrls;
  final bool? imagesChanged;

  UpdateSportClubDto({
    required this.name,
    required this.location,
    required this.description,
    required this.openTime,
    required this.closeTime,
    required this.lat,
    required this.lng,
    required this.isOpen,
    required this.categoryId,
    this.images,
    this.keptImageUrls,
    this.imagesChanged,
  });

  // Convert to FormData for multipart upload
  Future<FormData> toFormData() async {
    // Format duration to HH:MM:SS
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours.remainder(24));
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    }

    // Start with basic fields
    final Map<String, dynamic> fields = {
      'name': name,
      'location': location,
      'description': description,
      'open_time': formatDuration(openTime),
      'close_time': formatDuration(closeTime),
      'lat': lat,
      'lng': lng,
      'is_open': isOpen,
      'category_id': categoryId, // Changed from category_ids to category_id
    };

    // Add image-related fields if provided
    if (imagesChanged != null) {
      fields['images_changed'] = imagesChanged;
    }

    if (keptImageUrls != null && keptImageUrls!.isNotEmpty) {
      fields['kept_image_urls'] = keptImageUrls;
    }

    final formData = FormData.fromMap(fields);

    // Add image files if any
    if (images != null && images!.isNotEmpty) {
      for (var image in images!) {
        try {
          if (await image.exists()) {
            final fileName = path.basename(image.path);
            final fileSize = await image.length();

            if (fileSize > 0) {
              final multipartFile = await MultipartFile.fromFile(
                image.path,
                filename: fileName,
              );
              formData.files.add(MapEntry('images', multipartFile));
            }
          }
        } catch (e) {
          // Handle error
        }
      }
    }

    return formData;
  }

  // This method is for when you want to send JSON (not FormData)
  Map<String, dynamic> toJson() {
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours.remainder(24));
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    }

    final Map<String, dynamic> json = {
      'name': name,
      'location': location,
      'description': description,
      'open_time': formatDuration(openTime),
      'close_time': formatDuration(closeTime),
      'lat': lat,
      'lng': lng,
      'is_open': isOpen,
      'category_id': categoryId,
    };

    if (imagesChanged != null) {
      json['images_changed'] = imagesChanged;
    }

    if (keptImageUrls != null && keptImageUrls!.isNotEmpty) {
      json['kept_image_urls'] = keptImageUrls;
    }

    return json;
  }

  UpdateSportClubDto copyWith({
    String? name,
    String? location,
    String? description,
    Duration? openTime,
    Duration? closeTime,
    double? lat,
    double? lng,
    bool? isOpen,
    int? categoryId,
    List<File>? images,
    List<String>? keptImageUrls,
    bool? imagesChanged,
  }) {
    return UpdateSportClubDto(
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isOpen: isOpen ?? this.isOpen,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      keptImageUrls: keptImageUrls ?? this.keptImageUrls,
      imagesChanged: imagesChanged ?? this.imagesChanged,
    );
  }
}
