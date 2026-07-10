import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';

abstract class BookingService {
  Future<List<BookingModel>> fetchBookingBySportClub(
    int sportClubId,
    int page,
    int limit,
    String? status,
    DateTime? date,
  );
  Future<BookingModel> updateBookingStatus(int bookingId);
  Future<BookingModel> udpatePaymentStatus(
    int bookingId,
    String transactionRef,
  );
  bool get isLoading;
  String get error;
  List<BookingModel> get bookingModel;
}
