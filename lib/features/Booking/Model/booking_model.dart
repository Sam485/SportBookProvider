import 'package:flutter_application_1/features/Booking/Model/DTO/payment_dto.dart';
import 'package:flutter_application_1/features/Booking/Model/DTO/slot_dto.dart';
import 'package:flutter_application_1/features/Booking/Model/DTO/sport_club_dto.dart';
import 'package:flutter_application_1/features/Booking/Model/DTO/user_dto.dart';

class BookingModel {
  final int id;
  final UserDto user;
  final SlotDto slot;
  final SportClubDto sportClub;
  final DateTime bookingDate;
  final Duration startTime;
  final Duration endTime;
  final int totalAmount;
  final String status;
  final String note;
  final String paymentStatus;
  final PaymentDto payment;
  final DateTime cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.user,
    required this.slot,
    required this.sportClub,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    required this.note,
    required this.paymentStatus,
    required this.payment,
    required this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    Duration parseTimeToDuration(String timeString) {
      try {
        // Remove any whitespace
        timeString = timeString.trim();

        // Split by colon
        final parts = timeString.split(':');

        if (parts.length >= 2) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final seconds = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;

          // Ensure values are within valid ranges
          return Duration(
            hours: hours.clamp(0, 23),
            minutes: minutes.clamp(0, 59),
            seconds: seconds.clamp(0, 59),
          );
        }
        return Duration.zero;
      } catch (e) {
        return Duration.zero;
      }
    }

    return BookingModel(
      id: json['id'] ?? 0,
      user: UserDto.fromJson(json['user']),
      slot: SlotDto.fromJson(json['slot']),
      sportClub: SportClubDto.fromjson(json['sport_club']),
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: parseTimeToDuration(json['start_time']),
      endTime: parseTimeToDuration(json['end_time']),
      totalAmount: json['total_amount'] ?? 0,
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      payment: PaymentDto.fromJson(json['payment']),
      cancelledAt: json['cancelled_at'] ?? DateTime(0),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  BookingModel copyWith(
    int? id,
    UserDto? user,
    SlotDto? slot,
    SportClubDto? sportClub,
    DateTime? bookingDate,
    Duration? startTime,
    Duration? endTime,
    int? totalAmount,
    String? status,
    String? note,
    String? paymentStatus,
    PaymentDto? payment,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  ) {
    return BookingModel(
      id: id ?? this.id,
      user: user ?? this.user,
      slot: slot ?? this.slot,
      sportClub: sportClub ?? this.sportClub,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      note: note ?? this.note,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      payment: payment ?? this.payment,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
