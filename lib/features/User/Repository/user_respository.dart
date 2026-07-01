import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/User/Model/login_reponse.dart';
import 'package:flutter_application_1/features/User/Model/login_request.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';

class UserRespository {
  final Dio dio;
  UserRespository(this.dio);

  Future<LoginResponse> registerUser(RegisterUserModel register) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: register.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        // Check if response has error field
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<LoginResponse> login(LoginRequest login) async {
    try {
      final response = await dio.post('/auth/login', data: login.toJson());

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response has error field (even with 200 status)
        if (response.data is Map && response.data['error'] != null) {
          throw Exception(response.data['error']);
        }
        return LoginResponse.fromJson(response.data);
      } else {
        // Handle non-200 status codes
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

  // Helper method to handle Dio errors
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
