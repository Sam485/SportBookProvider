import 'package:flutter_application_1/features/Slot/model/slot_model.dart';

class GetAllSlotDto {
  final List<SlotModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllSlotDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllSlotDto.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = json['data'];
    return GetAllSlotDto(
      data: items.map((e) => SlotModel.fromJson(e)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
