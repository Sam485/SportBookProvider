import 'package:flutter_application_1/features/Category/model/category_model.dart';

abstract class CategoryService {
  Future<List<CategoriesModel>> fetchAllCategories(
    int page,
    int limit,
    String? search,
  );
  String get error;
  bool get loading;
  List<CategoriesModel> get categories;
}
