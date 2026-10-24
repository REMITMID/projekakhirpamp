import 'package:flutter_test/flutter_test.dart';
import 'package:projekakhirpamp/features/catalog/domain/models/book_model.dart';

void main() {
  group('BookModel Tests', () {
    test('fromJson and toJson should serialize correctly', () {
      final json = {
        'id': 'test-uuid-123',
        'book_code': 'BK-001',
        'title': 'Flutter Mastery',
        'author': 'John Doe',
        'publisher': 'Tech Press',
        'publication_year': 2024,
        'category': 'Teknologi',
        'rack_location': 'Rak A-1',
        'stock': 10,
      };

      final book = BookModel.fromJson(json);

      expect(book.id, 'test-uuid-123');
      expect(book.bookCode, 'BK-001');
      expect(book.title, 'Flutter Mastery');
      expect(book.author, 'John Doe');
      expect(book.publisher, 'Tech Press');
      expect(book.publicationYear, 2024);
      expect(book.category, 'Teknologi');
      expect(book.rackLocation, 'Rak A-1');
      expect(book.stock, 10);
      expect(book.isAvailable, true);

      final exportedJson = book.toJson();
      expect(exportedJson['id'], 'test-uuid-123');
      expect(exportedJson['book_code'], 'BK-001');
      expect(exportedJson['stock'], 10);
    });

    test('isAvailable should be false when stock is 0', () {
      final book = BookModel(
        bookCode: 'BK-002',
        title: 'Empty Stock Book',
        author: 'Jane Doe',
        publisher: 'Test Press',
        publicationYear: 2023,
        category: 'Fiksi',
        rackLocation: 'Rak B-1',
        stock: 0,
      );

      expect(book.isAvailable, false);
    });

    test('copyWith should properly update fields', () {
      final book = BookModel(
        bookCode: 'BK-003',
        title: 'Original Title',
        author: 'Author A',
        publisher: 'Publisher A',
        publicationYear: 2020,
        category: 'Sains',
        rackLocation: 'Rak C-1',
        stock: 5,
      );

      final updated = book.copyWith(
        title: 'Updated Title',
        stock: 12,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.stock, 12);
      expect(updated.bookCode, 'BK-003');
      expect(updated.author, 'Author A');
    });

    test('robust type parsing for string/num formats from database', () {
      final json = {
        'id': 'test-uuid',
        'book_code': 'BK-004',
        'title': 'Test Book',
        'author': 'Test Author',
        'publisher': 'Test Pub',
        'publication_year': '2022', // String from db
        'category': 'Teknologi',
        'rack_location': 'Rak D-1',
        'stock': '15', // String from db
      };

      final book = BookModel.fromJson(json);
      expect(book.publicationYear, 2022);
      expect(book.stock, 15);
    });
  });
}
