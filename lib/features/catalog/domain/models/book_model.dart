class BookModel {
  final String? id;
  final String bookCode;
  final String title;
  final String author;
  final String publisher;
  final int publicationYear;
  final String category;
  final String rackLocation;
  final int stock;

  BookModel({
    this.id,
    required this.bookCode,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.category,
    required this.rackLocation,
    required this.stock,
  });

  bool get isAvailable => stock > 0;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String?,
      bookCode: json['book_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      publicationYear: json['publication_year'] is int
          ? json['publication_year'] as int
          : int.tryParse(json['publication_year']?.toString() ?? '') ??
              DateTime.now().year,
      category: json['category']?.toString() ?? '',
      rackLocation: json['rack_location']?.toString() ?? '',
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'book_code': bookCode,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publication_year': publicationYear,
      'category': category,
      'rack_location': rackLocation,
      'stock': stock,
    };
  }

  BookModel copyWith({
    String? id,
    String? bookCode,
    String? title,
    String? author,
    String? publisher,
    int? publicationYear,
    String? category,
    String? rackLocation,
    int? stock,
  }) {
    return BookModel(
      id: id ?? this.id,
      bookCode: bookCode ?? this.bookCode,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      category: category ?? this.category,
      rackLocation: rackLocation ?? this.rackLocation,
      stock: stock ?? this.stock,
    );
  }
}
