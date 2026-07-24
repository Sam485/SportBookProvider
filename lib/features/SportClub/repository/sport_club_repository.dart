import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/created_sport_clubs_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/get_all_sport_club_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/update_sport_club_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/update_sport_club_images.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';

class SportClubRepository {
  final Dio dio;

  SportClubRepository(this.dio) {
    // Add interceptors for debugging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (object) {},
      ),
    );
  }

  Future<SportClubModel> createSportClub(CreatedSportClubsDto sportClub) async {
    try {
      // Convert DTO to FormData for multipart upload
      final formData = await sportClub.toFormData();

      final response = await dio.post(
        '/partner/sport-clubs',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SportClubModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSportclub(int sportClubId) async {
    try {
      final response = await dio.delete('/partner/sport-clubs/$sportClubId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<GetAllSportClubDto> getlAllSportClub(
    int page,
    int limit,
    String? search,
  ) async {
    try {
      final response = await dio.get(
        '/partner/sport-clubs/mine?page=$page&limit=$limit&search=$search',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSportClubDto.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<SportClubModel> updateSportClub(
    int sportClubId,
    UpdateSportClubDto sportclub,
  ) async {
    try {
      // Await the FormData
      final formData = await sportclub.toFormData();

      final response = await dio.put(
        '/partner/sport-clubs/$sportClubId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SportClubModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<SportClubModel> updateSportClubImage(
    UpdateSportClubImages sportclubImages,
    int sportClubId,
  ) async {
    try {
      // Convert DTO to FormData for multipart upload
      final formData = await sportclubImages.toFormData();

      final response = await dio.put(
        '/partner/sport-clubs/$sportClubId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SportClubModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {}
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to extract error message from response
  String _extractErrorMessage(dynamic data) {
    if (data == null) {
      return 'Unknown error occurred (null response)';
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) {
        return data['error'].toString();
      } else if (data.containsKey('message')) {
        return data['message'].toString();
      } else if (data.containsKey('msg')) {
        return data['msg'].toString();
      } else if (data.containsKey('errors')) {
        // Handle validation errors
        final errors = data['errors'];
        if (errors is Map) {
          return errors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
        }
        return errors.toString();
      } else if (data.containsKey('detail')) {
        return data['detail'].toString();
      } else {
        return 'Unknown error occurred: $data';
      }
    } else if (data is String) {
      return data;
    }

    return 'Invalid response from server: $data';
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
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
    } else if (e.type == DioExceptionType.badResponse) {
      return Exception('Bad response from server: ${e.response?.statusCode}');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
