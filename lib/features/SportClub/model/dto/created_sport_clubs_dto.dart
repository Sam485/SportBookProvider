import 'dart:io';

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'location': location,
      'is_open': isOpen,
      'open_time': openTime,
      'close_time': closeTime,
      'description': description,
      'category_id': categoryId,
      'images': images,
    };
  }

  CreatedSportClubsDto copyWith(
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
  ) {
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
