import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/category_rack_repository.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/rack_model.dart';
import '../../domain/models/category_rack_model.dart';

class CategoryRackProvider extends ChangeNotifier {
  final CategoryRackRepository _repository;
  CategoryRackProvider({CategoryRackRepository? repository})
      : _repository = repository ?? CategoryRackRepository();

  List<CategoryModel> _categories = [];
  List<RackModel> _racks = [];
  List<CategoryRackModel> _mappings = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<RackModel> get racks => List.unmodifiable(_racks);
  List<CategoryRackModel> get mappings => List.unmodifiable(_mappings);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  CategoryModel? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  RackModel? rackById(String id) {
    for (final rack in _racks) {
      if (rack.id == id) return rack;
    }
    return null;
  }

  /// Dropdown rak dibatasi menggunakan relasi category_racks.
  List<RackModel> racksForCategory(String? categoryId) {
    if (categoryId == null) return [];
    final allowedIds = _mappings.where((m) => m.categoryId == categoryId)
        .map((m) => m.rackId).toSet();
    return _racks.where((r) => allowedIds.contains(r.id)).toList();
  }

  bool isValidPair(String? categoryId, String? rackId) {
    if (categoryId == null || rackId == null) return false;
    return _mappings.any((m) => m.categoryId == categoryId && m.rackId == rackId);
  }

  Future<void> fetchCategoryRacks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Mengganti state hanya setelah seluruh referensi berhasil dibaca.
      final categories = await _repository.getCategories();
      final racks = await _repository.getRacks();
      final mappings = await _repository.getMappings();
      _categories = categories;
      _racks = racks;
      _mappings = mappings;
      _hasLoaded = true;
    } catch (e) {
      _hasLoaded = false;
      _errorMessage = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object e) {
    if (e is PostgrestException) {
      if (e.code == '23503') {
        return 'Data masih digunakan oleh buku atau relasi lainnya dan tidak dapat dihapus.';
      }
      if (e.code == '23505') {
        return 'Data/kombinasi tersebut sudah ada. Gunakan nama atau kode yang berbeda.';
      }
      if (e.code == '42501') {
        return 'Akses ditolak oleh kebijakan database (RLS).';
      }
      return e.message;
    }
    return e.toString();
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isSaving = false;
      notifyListeners();
      return false;
    }
    _isSaving = false;
    notifyListeners();
    await fetchCategoryRacks();
    return true; // Tulisan sukses walaupun refresh kemudian mengalami error.
  }

  Future<bool> addCategory(String name, String desc) =>
      _mutate(() => _repository.addCategory(name.trim(), desc.trim()));
  Future<bool> updateCategory(String id, String name, String desc) =>
      _mutate(() => _repository.updateCategory(id, name.trim(), desc.trim()));
  Future<bool> deleteCategory(String id) =>
      _mutate(() => _repository.deleteCategory(id));

  Future<bool> addRack(String code, String location) =>
      _mutate(() => _repository.addRack(code.trim().toUpperCase(), location.trim()));
  Future<bool> updateRack(String id, String code, String location) =>
      _mutate(() => _repository.updateRack(id, code.trim().toUpperCase(), location.trim()));
  Future<bool> deleteRack(String id) =>
      _mutate(() => _repository.deleteRack(id));

  Future<bool> addMapping(String categoryId, String rackId) {
    if (isValidPair(categoryId, rackId)) {
      _errorMessage = 'Pasangan kategori dan rak sudah terdaftar.';
      notifyListeners();
      return Future.value(false);
    }
    return _mutate(() => _repository.addMapping(categoryId, rackId));
  }
  Future<bool> deleteMapping(String id) =>
      _mutate(() => _repository.deleteMapping(id));
}
