import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/book_model.dart';

class BookRepository {
  final SupabaseClient? _injectedClient;
  BookRepository({SupabaseClient? client}) : _injectedClient = client;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  Future<List<BookModel>> fetchBooks() async {
    final rows = await _client.from('books').select('''
      id, book_code, title, author, publisher, publication_year,
      category_id, rack_id, stock, created_at,
      categories(name), racks(rack_code, location)
    ''').order('created_at', ascending: false);
    return rows.map(BookModel.fromJson).toList();
  }

  Future<void> addBook(BookModel book) async {
    await _client.from('books').insert(book.toJson());
  }

  Future<void> updateBook(BookModel book) async {
    if (book.id == null) throw StateError('ID buku harus ada untuk update.');
    final payload = book.toJson()..remove('id');
    final rows = await _client.from('books').update(payload)
        .eq('id', book.id!).select('id');
    if (rows.isEmpty) throw StateError('Buku tidak ditemukan atau akses ditolak.');
  }

  Future<void> deleteBook(String id) async {
    final rows = await _client.from('books').delete().eq('id', id).select('id');
    if (rows.isEmpty) throw StateError('Buku tidak ditemukan atau akses ditolak.');
  }
}