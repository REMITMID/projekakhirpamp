import 'package:flutter/material.dart';
import '../../data/category_rack_repository.dart';
import '../../domain/models/category_rack_model.dart';

class CategoryRackProvider with ChangeNotifier {
  final CategoryRackRepository _repository = CategoryRackRepository();

  List<CategoryRackModel> _categories = [];
  bool _isLoading = false;

  List<CategoryRackModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint('Error fetch categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String location) async {
    await _repository.addCategory(name, location);
    await fetchCategories();
  }

  Future<void> updateCategory(String id, String name, String location) async {
    await _repository.updateCategory(id, name, location);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await fetchCategories();
  }
}