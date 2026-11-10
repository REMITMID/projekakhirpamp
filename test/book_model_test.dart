import 'package:flutter_test/flutter_test.dart';
import 'package:projekakhirpamp/features/catalog/domain/models/book_model.dart';

void main() {
  const catId = 'a1000000-0000-0000-0000-000000000001';
  const rackId = 'b2000000-0000-0000-0000-000000000001';
  Map<String, dynamic> row() => {
    'id': 'id-buku-1',
    'book_code': 'BK-001',
    'title': 'Belajar Flutter',
    'author': 'Andi',
    'publisher': 'Pustaka',
    'publication_year': 2024,
    'category_id': catId,
    'rack_id': rackId,
    'stock': 5,
    'categories': {'name': 'Teknologi'},
    'racks': {'rack_code': 'RK-A01', 'location': 'Lantai 1'},
  };

  test('JOIN categories/racks dibaca untuk tampilan', () {
    final book = BookModel.fromJson(row());
    expect(book.categoryId, catId);
    expect(book.rackId, rackId);
    expect(book.category, 'Teknologi');
    expect(book.rackLocation, 'RK-A01 - Lantai 1');
    expect(book.isAvailable, true);
  });

  test('payload INSERT/UPDATE hanya atribut books termasuk kedua FK', () {
    final book = BookModel.fromJson(row());
    final payload = book.toJson();
    expect(payload['category_id'], catId);
    expect(payload['rack_id'], rackId);
    expect(payload.containsKey('category'), false);
    expect(payload.containsKey('rack_location'), false);
    expect(payload.containsKey('category_rack_id'), false);
    expect(payload.containsKey('categories'), false);
    expect(payload.containsKey('racks'), false);
  });

  test('copyWith mempertahankan referensi dan mengubah stok', () {
    final updated = BookModel.fromJson(row()).copyWith(stock: 0);
    expect(updated.stock, 0);
    expect(updated.isAvailable, false);
    expect(updated.categoryId, catId);
    expect(updated.rackId, rackId);
  });

  test('data JOIN tidak ada tidak disamarkan menjadi nilai kosong', () {
    final json = row()..remove('categories');
    expect(() => BookModel.fromJson(json), throwsFormatException);
  });
}