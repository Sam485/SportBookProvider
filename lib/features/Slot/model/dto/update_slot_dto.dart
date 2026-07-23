class UpdateSlotDto {
  final String name;
  final int price;
  final bool isAvailable;
  final String description;
  final int capacity;

  UpdateSlotDto({
    required this.name,
    required this.price,
    required this.isAvailable,
    required this.description,
    required this.capacity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'is_available': isAvailable,
      'description': description,
      'capacity': capacity,
    };
  }

  UpdateSlotDto copyWith({
    String? name,
    int? price,
    bool? isAvailable,
    String? description,
    int? capacity,
  }) {
    return UpdateSlotDto(
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
    );
  }
}
