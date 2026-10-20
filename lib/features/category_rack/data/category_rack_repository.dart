import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/category_rack_model.dart';

class CategoryRackRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CategoryRackModel>> getCategories() async {
    final response = await _supabase
        .from('category_rack')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => CategoryRackModel.fromJson(e)).toList();
  }

  Future<void> addCategory(String name, String location) async {
    await _supabase.from('category_rack').insert({
      'category_name': name,
      'rack_location': location,
    });
  }

  Future<void> updateCategory(String id, String name, String location) async {
    await _supabase.from('category_rack').update({
      'category_name': name,
      'rack_location': location,
    }).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('category_rack').delete().eq('id', id);
  }
}