import 'package:flutter/material.dart';
import '../../data/book_repository.dart';
import '../../domain/models/book_model.dart';

class BookProvider extends ChangeNotifier {
  final BookRepository _repository = BookRepository();

  List<BookModel> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGridView = false;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  BookModel? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _repository.fetchBooks();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBook(BookModel book) async {
    _errorMessage = null;
    try {
      await _repository.addBook(book);
      await fetchBooks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(BookModel book) async {
    _errorMessage = null;
    try {
      await _repository.updateBook(book);
      await fetchBooks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(String id) async {
    _errorMessage = null;
    try {
      await _repository.deleteBook(id);
      await fetchBooks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
