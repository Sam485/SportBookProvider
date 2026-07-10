import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/Slot/model/dto/create_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/dto/update_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/slot_model.dart';

class SlotRepository {
  final Dio dio;
  SlotRepository(this.dio);

  Future<SlotModel> createSlot(CreateSlotDto slot) async {
    try {
      final response = await dio.post('/partner/slots', data: slot.toJson());
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
        return SlotModel.fromJson(response.data);
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
      final response = await dio.put(
        '/partner/slots/$slotId',
        data: {'name': courtName, 'image': image},
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
