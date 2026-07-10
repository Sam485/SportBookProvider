import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';

class GetAllBookingDto {
  final List<BookingModel> data;
  final int total;
  final int page;
  final int limit;
  GetAllBookingDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });
  factory GetAllBookingDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['data'] ?? json;
    return GetAllBookingDto(
      data: items.map((e) => BookingModel.fromJson(e)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
