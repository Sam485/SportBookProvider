import 'package:flutter_application_1/features/Category/model/category_model.dart';
import 'package:flutter_application_1/features/Category/repository/category_repository.dart';
import 'package:flutter_application_1/features/Category/service/category_service.dart';

class CategoryServiceImp implements CategoryService {
  CategoryRepository categoryRepository;
  CategoryServiceImp(this.categoryRepository);

  List<CategoriesModel> _categories = [];
  String _error = '';
  bool _loading = false;

  @override
  List<CategoriesModel> get categories => _categories;

  @override
  String get error => _error;

  @override
  bool get loading => _loading;

  @override
  Future<List<CategoriesModel>> fetchAllCategories(
    int page,
    int limit,
    String? search,
  ) async {
    _categories = [];
    _loading = true;
    try {
      final data = await categoryRepository.getAllCategories(
        page,
        limit,
        search,
      );
      _loading = false;
      _categories = data.data;
      return _categories;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      rethrow;
    }
  }
}
