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
        logPrint: (object) {
          print(object);
        },
      ),
    );
  }

  Future<SportClubModel> createSportClub(CreatedSportClubsDto sportClub) async {
    try {
      print('📤 [CREATE SPORT CLUB] Starting...');
      print('📤 [CREATE SPORT CLUB] Club name: ${sportClub.name}');
      print('📤 [CREATE SPORT CLUB] Images count: ${sportClub.images.length}');

      // Convert DTO to FormData for multipart upload
      final formData = await sportClub.toFormData();

      print('📤 [CREATE SPORT CLUB] FormData fields:');
      formData.fields.forEach((field) {
        print('  - ${field.key}: ${field.value}');
      });

      print('📤 [CREATE SPORT CLUB] FormData files:');
      formData.files.forEach((file) {
        print(
          '  - ${file.key}: ${file.value.filename} (${file.value.length} bytes)',
        );
      });

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

      print('✅ [CREATE SPORT CLUB] Response status: ${response.statusCode}');
      print('✅ [CREATE SPORT CLUB] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SportClubModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        print('❌ [CREATE SPORT CLUB] Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ [CREATE SPORT CLUB] DioException: ${e.message}');
      print('❌ [CREATE SPORT CLUB] Response: ${e.response?.data}');
      print('❌ [CREATE SPORT CLUB] Status code: ${e.response?.statusCode}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [CREATE SPORT CLUB] Unexpected error: $e');
      rethrow;
    }
  }

  Future<bool> deleteSportclub(int sportClubId) async {
    try {
      print('📤 [DELETE SPORT CLUB] Deleting club ID: $sportClubId');

      final response = await dio.delete('/partner/sport-clubs/$sportClubId');

      print('✅ [DELETE SPORT CLUB] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        print('❌ [DELETE SPORT CLUB] Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ [DELETE SPORT CLUB] DioException: ${e.message}');
      print('❌ [DELETE SPORT CLUB] Response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<GetAllSportClubDto> getlAllSportClub(
    int page,
    int limit,
    String? search,
  ) async {
    try {
      print('📤 [GET SPORT CLUBS] Page: $page, Limit: $limit, Search: $search');

      final response = await dio.get(
        '/partner/sport-clubs/mine?page=$page&limit=$limit&search=$search',
      );

      print('✅ [GET SPORT CLUBS] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSportClubDto.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        print('❌ [GET SPORT CLUBS] Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ [GET SPORT CLUBS] DioException: ${e.message}');
      print('❌ [GET SPORT CLUBS] Response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<SportClubModel> updateSportClub(
    int sportClubId,
    UpdateSportClubDto sportclub,
  ) async {
    try {
      print('📤 [UPDATE SPORT CLUB] Club ID: $sportClubId');
      print('📤 [UPDATE SPORT CLUB] Club name: ${sportclub.name}');
      print('📤 [UPDATE SPORT CLUB] Category ID: ${sportclub.categoryId}');
      print('📤 [UPDATE SPORT CLUB] Images: ${sportclub.images?.length ?? 0}');
      print(
        '📤 [UPDATE SPORT CLUB] Kept images: ${sportclub.keptImageUrls?.length ?? 0}',
      );
      print(
        '📤 [UPDATE SPORT CLUB] Images changed: ${sportclub.imagesChanged}',
      );

      // Await the FormData
      final formData = await sportclub.toFormData();

      print('📤 [UPDATE SPORT CLUB] FormData fields:');
      formData.fields.forEach((field) {
        print('  - ${field.key}: ${field.value}');
      });

      print('📤 [UPDATE SPORT CLUB] FormData files:');
      formData.files.forEach((file) {
        print(
          '  - ${file.key}: ${file.value.filename} (${file.value.length} bytes)',
        );
      });

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

      print('✅ [UPDATE SPORT CLUB] Response status: ${response.statusCode}');
      print('✅ [UPDATE SPORT CLUB] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SportClubModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        print('❌ [UPDATE SPORT CLUB] Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ [UPDATE SPORT CLUB] DioException: ${e.message}');
      print('❌ [UPDATE SPORT CLUB] Response: ${e.response?.data}');
      print('❌ [UPDATE SPORT CLUB] Status code: ${e.response?.statusCode}');
      if (e.response?.data != null) {
        print('❌ [UPDATE SPORT CLUB] Error details: ${e.response?.data}');
      }
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [UPDATE SPORT CLUB] Unexpected error: $e');
      rethrow;
    }
  }

  Future<SportClubModel> updateSportClubImage(
    UpdateSportClubImages sportclubImages,
    int sportClubId,
  ) async {
    try {
      print('📤 [UPDATE SPORT CLUB IMAGE] Club ID: $sportClubId');
      print('📤 [UPDATE SPORT CLUB IMAGE] Name: ${sportclubImages.name}');
      print('📤 [UPDATE SPORT CLUB IMAGE] Is Open: ${sportclubImages.isOpen}');
      print(
        '📤 [UPDATE SPORT CLUB IMAGE] Images changed: ${sportclubImages.imagesChanged}',
      );
      print(
        '📤 [UPDATE SPORT CLUB IMAGE] Kept image URLs: ${sportclubImages.keptImageUrls}',
      );
      print(
        '📤 [UPDATE SPORT CLUB IMAGE] New images: ${sportclubImages.images?.length ?? 0}',
      );

      // Convert DTO to FormData for multipart upload
      final formData = await sportclubImages.toFormData();

      print('📤 [UPDATE SPORT CLUB IMAGE] FormData fields:');
      formData.fields.forEach((field) {
        print('  - ${field.key}: ${field.value}');
      });

      print('📤 [UPDATE SPORT CLUB IMAGE] FormData files:');
      formData.files.forEach((file) {
        print(
          '  - ${file.key}: ${file.value.filename} (${file.value.length} bytes)',
        );
      });

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

      print(
        '✅ [UPDATE SPORT CLUB IMAGE] Response status: ${response.statusCode}',
      );
      print('✅ [UPDATE SPORT CLUB IMAGE] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SportClubModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        print('❌ [UPDATE SPORT CLUB IMAGE] Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ [UPDATE SPORT CLUB IMAGE] DioException: ${e.message}');
      print('❌ [UPDATE SPORT CLUB IMAGE] Response: ${e.response?.data}');
      print(
        '❌ [UPDATE SPORT CLUB IMAGE] Status code: ${e.response?.statusCode}',
      );
      if (e.response?.data != null) {
        print('❌ [UPDATE SPORT CLUB IMAGE] Error details: ${e.response?.data}');
      }
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [UPDATE SPORT CLUB IMAGE] Unexpected error: $e');
      rethrow;
    }
  }

  // Helper method to extract error message from response
  String _extractErrorMessage(dynamic data) {
    print('🔍 [EXTRACT ERROR] Data type: ${data.runtimeType}');
    print('🔍 [EXTRACT ERROR] Data: $data');

    if (data == null) {
      return 'Unknown error occurred (null response)';
    }

    if (data is Map<String, dynamic>) {
      print('🔍 [EXTRACT ERROR] Keys: ${data.keys}');

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
    print('🔍 [HANDLE DIO ERROR] Type: ${e.type}');
    print('🔍 [HANDLE DIO ERROR] Message: ${e.message}');

    if (e.response != null) {
      final errorMessage = _extractErrorMessage(e.response?.data);
      print('🔍 [HANDLE DIO ERROR] Extracted error: $errorMessage');
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
