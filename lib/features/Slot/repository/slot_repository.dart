import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/Slot/model/dto/create_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/dto/get_all_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/dto/update_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/slot_model.dart';
import 'package:path/path.dart' as path;

class SlotRepository {
  final Dio dio;
  SlotRepository(this.dio);

  Future<SlotModel> createSlot(CreateSlotDto slot) async {
    try {
      // Use FormData for file upload
      final formData = await slot.toFormData();

      // Set appropriate headers for multipart/form-data
      final response = await dio.post(
        '/partner/slots',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SlotModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<SlotModel> updateSlot(UpdateSlotDto updateSlot, int slotId) async {
    try {
      final response = await dio.put(
        '/partner/slots/$slotId',
        data: updateSlot.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<SlotModel> updateSlotImage(
    int slotId,
    File image,
    String courtName,
  ) async {
    try {
      // Always use FormData for image upload
      final fileName = path.basename(image.path);
      final imageFile = await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        'name': courtName,
        'image': imageFile,
      });

      final response = await dio.put(
        '/partner/slots/$slotId',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SlotModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<SlotModel> removeSlotImage(int slotId) async {
    try {
      final response = await dio.put(
        '/partner/slots/$slotId',
        data: {'images_changed': true, 'kept_image_url': null},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SlotModel.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> deleteSlot(int slotId) async {
    try {
      final response = await dio.delete('/partner/slots/$slotId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<GetAllSlotDto> getSlotBySportClub(
    int clubId,
    int page,
    int limit,
    int? categoryId,
  ) async {
    try {
      final response = await dio.get(
        '/sport-clubs/$clubId/slots?page=$page&limit=$limit&available=&search=&category_id=${categoryId ?? ''}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllSlotDto.fromJson(response.data);
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode);
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
