import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/category_model.dart';
import '../domain/models/rack_model.dart';
import '../domain/models/category_rack_model.dart';

/// Akses tiga tabel normalisasi, tidak lagi menggunakan tabel category_rack.
class CategoryRackRepository {
  final SupabaseClient? _injectedClient;
  CategoryRackRepository({SupabaseClient? client}) : _injectedClient = client;
  SupabaseClient get _db => _injectedClient ?? Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    final rows = await _db.from('categories').select('id, name, description')
        .order('name', ascending: true);
    return rows.map(CategoryModel.fromJson).toList();
  }

  Future<List<RackModel>> getRacks() async {
    final rows = await _db.from('racks').select('id, rack_code, location')
        .order('rack_code', ascending: true);
    return rows.map(RackModel.fromJson).toList();
  }

  Future<List<CategoryRackModel>> getMappings() async {
    final rows = await _db.from('category_racks').select('id, category_id, rack_id');
    return rows.map(CategoryRackModel.fromJson).toList();
  }

  Future<void> addCategory(String name, String description) async {
    await _db.from('categories').insert({
      'name': name,
      'description': description.isEmpty ? null : description,
    });
  }

  Future<void> updateCategory(String id, String name, String description) async {
    final rows = await _db.from('categories').update({
      'name': name,
      'description': description.isEmpty ? null : description,
    }).eq('id', id).select('id');
    if (rows.isEmpty) throw StateError('Kategori tidak ditemukan atau akses ditolak.');
  }

  Future<void> deleteCategory(String id) async {
    final rows = await _db.from('categories').delete().eq('id', id).select('id');
    if (rows.isEmpty) throw StateError('Kategori tidak ditemukan atau akses ditolak.');
  }

  Future<void> addRack(String code, String location) async {
    await _db.from('racks').insert({'rack_code': code, 'location': location});
  }

  Future<void> updateRack(String id, String code, String location) async {
    final rows = await _db.from('racks')
        .update({'rack_code': code, 'location': location})
        .eq('id', id).select('id');
    if (rows.isEmpty) throw StateError('Rak tidak ditemukan atau akses ditolak.');
  }

  Future<void> deleteRack(String id) async {
    final rows = await _db.from('racks').delete().eq('id', id).select('id');
    if (rows.isEmpty) throw StateError('Rak tidak ditemukan atau akses ditolak.');
  }

  Future<void> addMapping(String categoryId, String rackId) async {
    await _db.from('category_racks').insert({
      'category_id': categoryId,
      'rack_id': rackId,
    });
  }

  Future<void> deleteMapping(String id) async {
    final rows = await _db.from('category_racks')
        .delete().eq('id', id).select('id');
    if (rows.isEmpty) throw StateError('Pasangan tidak ditemukan atau akses ditolak.');
  }
}