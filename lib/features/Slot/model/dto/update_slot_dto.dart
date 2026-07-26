import 'package:dio/dio.dart';

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

  FormData toFormData() {
    // Use FormData.fromMap without await since it's synchronous
    return FormData.fromMap({
      'name': name,
      'price': price,
      'is_available': isAvailable,
      'description': description,
      'capacity': capacity,
    });
  }
}
