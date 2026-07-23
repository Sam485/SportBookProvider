import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/User/Model/login_reponse.dart';
import 'package:flutter_application_1/features/User/Model/login_request.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Model/update_password_model.dart';
import 'package:flutter_application_1/features/User/Model/update_user_model.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';

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

  Future<UserModel> getUserProfile() async {
    try {
      final response = await dio.get('/users/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> updateUserProfile(UpdateUserModel update) async {
    try {
      final response = await dio.put('/users/me', data: update.toJson());
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> updateUserPassword(
    UpdatePasswordModel updatePassword,
  ) async {
    try {
      final response = await dio.put(
        '/user/me/password',
        data: updatePassword.toJson(),
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> uploadAvatar(File avatar) async {
    try {
      // Check if file exists
      if (!await avatar.exists()) {
        throw Exception('File does not exist: ${avatar.path}');
      }

      // Get file size
      final fileSize = await avatar.length();

      // Check file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('File too large. Maximum size is 5MB.');
      }

      // Create multipart file with proper naming
      final fileName = avatar.path.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        avatar.path,
        filename: fileName,
        contentType: _getContentType(fileName),
      );

      // Create FormData with the file
      final formData = FormData.fromMap({'avatar': multipartFile});

      final response = await dio.post(
        '/users/me/avatar',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) {
            // Allow all status codes to be handled in code
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try to parse the response
        UserModel? updatedUser;

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // If response contains user data directly
          if (data.containsKey('id') || data.containsKey('full_name')) {
            updatedUser = UserModel.fromJson(data);
          }
          // If response contains user wrapped in data field
          else if (data.containsKey('data')) {
            final userData = data['data'];
            if (userData is Map<String, dynamic>) {
              updatedUser = UserModel.fromJson(userData);
            }
          }
          // If response just contains avatar URL
          else if (data.containsKey('avatar_url')) {
            // Fetch full user data
            updatedUser = await getUserProfile();
          }
        }

        // If we couldn't parse the response, fetch fresh user data
        updatedUser ??= await getUserProfile();

        return updatedUser;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Try to extract error message
      String errorMessage = 'Upload failed';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            errorMessage =
                data['message'] ??
                data['error'] ??
                data['detail'] ??
                'Upload failed';
          } else if (data is String) {
            errorMessage = data;
          }
        } catch (parseError) {
          // Ignore parsing errors
        }
      }

      // Handle specific error codes
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid file format. Please upload a valid image.');
      } else if (e.response?.statusCode == 413) {
        throw Exception('File too large. Maximum size is 5MB.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Please login again to upload avatar.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Helper method to determine content type
  DioMediaType _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return DioMediaType('image', 'jpeg');
      case 'png':
        return DioMediaType('image', 'png');
      case 'gif':
        return DioMediaType('image', 'gif');
      case 'webp':
        return DioMediaType('image', 'webp');
      case 'bmp':
        return DioMediaType('image', 'bmp');
      default:
        return DioMediaType('image', 'jpeg');
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
