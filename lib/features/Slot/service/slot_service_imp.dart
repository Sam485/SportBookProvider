import 'dart:io';

import 'package:flutter_application_1/features/Slot/model/dto/create_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/dto/update_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/slot_model.dart';
import 'package:flutter_application_1/features/Slot/repository/slot_repository.dart';
import 'package:flutter_application_1/features/Slot/service/slot_service.dart';

class SlotServiceImp implements SlotService {
  SlotRepository repository;
  SlotServiceImp(this.repository);
  String _error = '';
  bool _loading = false;
  @override
  String get error => _error;

  @override
  bool get loading => _loading;

  @override
  Future<SlotModel> createSlot(CreateSlotDto slot) async {
    _error = '';
    _loading = true;
    try {
      final data = await repository.createSlot(slot);
      _loading = false;
      return data;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<bool> deleteSlot(int slotId) async {
    _error = '';
    _loading = true;
    try {
      final status = await repository.deleteSlot(slotId);
      _loading = false;
      return status;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<SlotModel> removeSlotImage(int slotId) async {
    _error = '';
    _loading = true;
    try {
      final status = await repository.removeSlotImage(slotId);
      _loading = false;
      return status;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<SlotModel> updateSlot(UpdateSlotDto updateSlot, int slotId) async {
    _error = '';
    _loading = true;
    try {
      final reponse = await repository.updateSlot(updateSlot, slotId);
      _loading = false;
      return reponse;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<SlotModel> updateSlotImage(
    int slotId,
    File image,
    String courtName,
  ) async {
    _error = '';
    _loading = true;
    try {
      final response = await repository.updateSlotImage(
        slotId,
        image,
        courtName,
      );
      _loading = false;
      return response;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<List<SlotModel>> fetchSlotBySportClub(
    int clubId,
    int page,
    int limit,
    int? categoryId,
  ) async {
    _error = '';
    _loading = true;
    try {
      final response = await repository.getSlotBySportClub(
        clubId,
        page,
        limit,
        categoryId,
      );
      final slots = response.data;
      return slots;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      rethrow;
    }
  }
}
