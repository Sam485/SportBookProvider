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
  final CategoryDto category;
  final UserDto createdBy;
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
    required this.category,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      capacity: json['capacity'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      sportClubId: json['sportClubId'] ?? 0,
      category: CategoryDto.fromJson(json['cateogry']),
      createdBy: UserDto.fromjson(json['created_by']),
      createdAt: json['created_at'] ?? DateTime(0),
      updatedAt: json['updated_at'] ?? DateTime(0),
    );
  }

  SlotModel copyWith(
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
  ) {
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
      updatedAt: updatedAt ?? this.createdAt,
    );
  }
}
