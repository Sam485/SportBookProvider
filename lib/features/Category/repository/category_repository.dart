import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/Category/model/get_all_category_model.dart';

class CategoryRepository {
  final Dio dio;
  CategoryRepository(this.dio);

  Future<GetAllCategoryModel> getAllCategories(
    int page,
    int limit,
    String? search,
  ) async {
    try {
      final response = await dio.get(
        '/categories?page=$page&limit=$limit&search=$search',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllCategoryModel.fromJson(response.data);
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
