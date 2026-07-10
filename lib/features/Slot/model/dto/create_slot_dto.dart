import 'dart:io';

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

  Map<String, dynamic> toJson() {
    return {
      'sport_club_id': sportClubId,
      'name': name,
      'description': description,
      'price': price,
      'capacity': capacity,
      'is_available': isAvailable,
      'category_id': categoryId,
      'image': image,
    };
  }

  CreateSlotDto copyWith(
    int? sportClubId,
    String? name,
    String? description,
    double? price,
    int? capacity,
    bool? isAvailable,
    int? categoryId,
    File? image,
  ) {
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
