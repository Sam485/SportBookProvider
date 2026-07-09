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
    return SportClubModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: json['lat'] ?? 0.00,
      lng: json['lng'] ?? 0.00,
      location: json['location'] ?? '',
      isOpen: json['isOpen'] ?? false,
      openTime: json['open_time'] ?? Duration(days: 0),
      closeTime: json['close_time'] ?? Duration(days: 0),
      description: json['description'] ?? Duration(days: 0),
      imageUrls: json['image_urls'] ?? [],
      favoriteCount: json['favorite_count'] ?? 0,
      categories: json['categories']
          .map((cat) => CategoryDto.fromJson(cat))
          .toList(),
      createdBy: UserDto.fromjson(json['created_by']),
      createdAt: json['created_at'] ?? DateTime(0),
      updatedAt: json['updated_at'] ?? DateTime(0),
    );
  }

  SportClubModel copyWith(
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
  ) {
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
