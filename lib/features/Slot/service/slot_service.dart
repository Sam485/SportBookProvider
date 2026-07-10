import 'dart:io';

import 'package:flutter_application_1/features/Slot/model/dto/create_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/dto/update_slot_dto.dart';
import 'package:flutter_application_1/features/Slot/model/slot_model.dart';

abstract class SlotService {
  Future<SlotModel> createSlot(CreateSlotDto slot);
  Future<SlotModel> updateSlot(UpdateSlotDto updateSlot,int slotId);
  Future<SlotModel> updateSlotImage(int slotId, File image, String courtName);
  Future<SlotModel> removeSlotImage(int slotId);
  Future<bool> deleteSlot(int slotId);

  bool get loading;
  String get error;
}
