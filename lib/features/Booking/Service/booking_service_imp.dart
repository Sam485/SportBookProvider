import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';
import 'package:flutter_application_1/features/Booking/Repository/booking_repository.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service.dart';

class BookingServiceImp implements BookingService {
  BookingRepository bookingRepository;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String _error = '';

  @override
  List<BookingModel> get bookingModel => _bookings;
  @override
  String get error => _error;
  @override
  bool get isLoading => _isLoading;
  BookingServiceImp(this.bookingRepository);

  @override
  Future<List<BookingModel>> fetchBookingBySportClub(
    int sportClubId,
    int page,
    int limit,
    String? status,
    DateTime? date,
  ) async {
    _isLoading = true;
    _error = '';
    try {
      final dto = await bookingRepository.getBookingBySportClub(
        sportClubId,
        page,
        limit,
        status,
        date,
      );
      var data = dto.data;
      _bookings = data;
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  @override
  Future<BookingModel> udpatePaymentStatus(
    int bookingId,
    String transactionRef,
  ) async {
    _isLoading = true;
    _error = '';
    try {
      final data = await bookingRepository.updatePaymentStatus(
        bookingId,
        transactionRef,
      );
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  @override
  Future<BookingModel> updateBookingStatus(int bookingId) async {
    _isLoading = false;
    _error = '';
    try {
      final data = await bookingRepository.updateBookingStatus(bookingId);
      _isLoading = false;
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }
}
