import 'dart:io';

class UpdateSportClubDto {
  final String name;
  final bool isOpen;
  final bool imagesChanges;
  final String keptImageUrls;
  final List<File> images;

  UpdateSportClubDto({
    required this.name,
    required this.isOpen,
    required this.imagesChanges,
    required this.keptImageUrls,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_open': isOpen,
      'images_changes': imagesChanges,
      'kept_image_urls': keptImageUrls,
      'images': images,
    };
  }

  UpdateSportClubDto copyWith(
    String? name,
    bool? isOpen,
    bool? imagesChanges,
    String? keptImageUrls,
    List<File>? images,
  ) {
    return UpdateSportClubDto(
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      imagesChanges: imagesChanges ?? this.imagesChanges,
      keptImageUrls: keptImageUrls ?? this.keptImageUrls,
      images: images ?? this.images,
    );
  }
}
