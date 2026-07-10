class CategoryDto {
  final int id;
  final String name;
  final String imageUrl;

  CategoryDto({required this.id, required this.name, required this.imageUrl});

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  CategoryDto copyWith(int? id, String? name, String? imageUrl) {
    return CategoryDto(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
