class UpdateSlotDto {
  final String name;
  final double price;
  final bool isAvailable;
  final String keptImageUrl;

  UpdateSlotDto({
    required this.name,
    required this.price,
    required this.isAvailable,
    required this.keptImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'is_available': isAvailable,
      'kept_image_url': keptImageUrl,
    };
  }

  UpdateSlotDto copyWith(
    String? name,
    double? price,
    bool? isAvailable,
    String? keptImageUrl,
  ) {
    return UpdateSlotDto(
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      keptImageUrl: keptImageUrl ?? this.keptImageUrl,
    );
  }
}
