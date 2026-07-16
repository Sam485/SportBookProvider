import 'package:flutter_application_1/features/SportClub/model/dto/category_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/user_dto.dart';

class SlotModel {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final int price;
  final int capacity;
  final bool isAvailable;
  final int sportClubId;
  final CategoryDto? category; // Made nullable
  final UserDto? createdBy; // Made nullable
  final DateTime createdAt;
  final DateTime updatedAt;

  SlotModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.capacity,
    required this.isAvailable,
    required this.sportClubId,
    this.category, // Now optional
    this.createdBy, // Now optional
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      capacity: json['capacity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      sportClubId: json['sport_club_id'] ?? 0,
      // Safe handling for category - check if it exists and is not null
      category: json['category'] != null
          ? CategoryDto.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      // Safe handling for createdBy
      createdBy: json['created_by'] != null
          ? UserDto.fromjson(json['created_by'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  SlotModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? description,
    int? price,
    int? capacity,
    bool? isAvailable,
    int? sportClubId,
    CategoryDto? category,
    UserDto? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SlotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      isAvailable: isAvailable ?? this.isAvailable,
      sportClubId: sportClubId ?? this.sportClubId,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
