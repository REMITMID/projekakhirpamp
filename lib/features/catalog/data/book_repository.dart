import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/book_model.dart';

class BookRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'books';

  Future<List<BookModel>> fetchBooks() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => BookModel.fromJson(e)).toList();
  }

  Future<void> addBook(BookModel book) async {
    await _client.from(_tableName).insert(book.toJson());
  }

  Future<void> updateBook(BookModel book) async {
    await _client
        .from(_tableName)
        .update(book.toJson())
        .eq('id', book.id!);
  }

  Future<void> deleteBook(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}