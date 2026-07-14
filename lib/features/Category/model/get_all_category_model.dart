import 'package:flutter_application_1/features/Category/model/category_model.dart';
import 'package:flutter_application_1/screens/settings/Features/venue_photos_screen.dart';

class GetAllCategoryModel {
  final List<CategoriesModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllCategoryModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllCategoryModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['data'];
    return GetAllCategoryModel(
      data: items.map((e) => CategoriesModel.fromJson(e)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
