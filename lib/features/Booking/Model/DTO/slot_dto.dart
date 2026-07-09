class SlotDto {
  final int id;
  final String name;
  final String imageUrl;
  final int price;

  SlotDto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory SlotDto.fromJson(Map<String, dynamic> json) {
    return SlotDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  SlotDto copyWith(int? id, String? name, String? imageUrl, int? price) {
    return SlotDto(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
    );
  }
}
