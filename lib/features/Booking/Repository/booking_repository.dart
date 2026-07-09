import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/Booking/Model/DTO/get_all_booking_dto.dart';
import 'package:flutter_application_1/features/Booking/Model/booking_model.dart';

class BookingRepository {
  final Dio dio;
  BookingRepository(this.dio);

  Future<GetAllBookingDto> getBookingBySportClub(
    int sportClubId,
    int page,
    int limit,
    String? status,
    DateTime? date,
  ) async {
    try {
      var response = await dio.get(
        '/partner/sport-clubs/$sportClubId/bookings?page=$page&limit=$limit&status=$status&date=$date',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllBookingDto.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<BookingModel> updateBookingStatus(int bookingId) async {
    try {
      final response = await dio.put(
        '/partner/bookings/$bookingId/status',
        data: {'status': 'confirmed'},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<BookingModel> updatePaymentStatus(
    int bookingId,
    String transactionRef,
  ) async {
    try {
      final response = await dio.put('/partner/bookings/$bookingId/payment');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Helper method to extract error message from response
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check for different error field names
      if (data.containsKey('error')) {
        return data['error'].toString();
      } else if (data.containsKey('message')) {
        return data['message'].toString();
      } else if (data.containsKey('msg')) {
        return data['msg'].toString();
      } else {
        return 'Unknown error occurred';
      }
    }
    return 'Invalid response from server';
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      // Try to extract error from response
      final errorMessage = _extractErrorMessage(e.response?.data);
      return Exception(errorMessage);
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception(
        'Connection timeout. Please check your internet connection.',
      );
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return Exception('Receive timeout. Server is not responding.');
    } else if (e.type == DioExceptionType.cancel) {
      return Exception('Request was cancelled.');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
