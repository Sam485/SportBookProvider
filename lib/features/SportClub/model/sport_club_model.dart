import 'package:flutter_application_1/features/SportClub/model/dto/category_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/user_dto.dart';

class SportClubModel {
  final int? id;
  final String name;
  final double lat;
  final double lng;
  final String location;
  final bool isOpen;
  final Duration openTime;
  final Duration closeTime;
  final String description;
  final List<String> imageUrls;
  final int favoriteCount;
  final List<CategoryDto> categories;
  final UserDto createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SportClubModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.location,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.description,
    required this.imageUrls,
    required this.favoriteCount,
    required this.categories,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SportClubModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse time string to Duration
    Duration parseTimeToDuration(String timeString) {
      try {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
          return Duration(hours: hours, minutes: minutes, seconds: seconds);
        }
        return Duration.zero;
      } catch (e) {
        return Duration.zero;
      }
    }

    return SportClubModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      isOpen: json['is_open'] ?? false, // Changed from 'isOpen' to 'is_open'
      openTime: json['open_time'] != null
          ? parseTimeToDuration(json['open_time'].toString())
          : Duration.zero,
      closeTime: json['close_time'] != null
          ? parseTimeToDuration(json['close_time'].toString())
          : Duration.zero,
      description: json['description'] ?? '',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      favoriteCount: json['favorite_count'] ?? 0,
      categories: json['categories'] != null
          ? (json['categories'] as List)
                .map((cat) => CategoryDto.fromJson(cat))
                .toList()
          : [],
      createdBy: UserDto.fromjson(json['created_by']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // Helper method to format Duration to time string (HH:MM:SS)
  String formatDurationToTimeString() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(openTime.inHours.remainder(24));
    final minutes = twoDigits(openTime.inMinutes.remainder(60));
    final seconds = twoDigits(openTime.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // Get formatted open time as string
  String get formattedOpenTime {
    return formatDurationToTimeString();
  }

  // Get formatted close time as string
  String get formattedCloseTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(closeTime.inHours.remainder(24));
    final minutes = twoDigits(closeTime.inMinutes.remainder(60));
    final seconds = twoDigits(closeTime.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  SportClubModel copyWith({
    int? id,
    String? name,
    double? lat,
    double? lng,
    String? location,
    bool? isOpen,
    Duration? openTime,
    Duration? closeTime,
    String? description,
    List<String>? imageUrls,
    int? favoriteCount,
    List<CategoryDto>? categories,
    UserDto? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SportClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      categories: categories ?? this.categories,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
