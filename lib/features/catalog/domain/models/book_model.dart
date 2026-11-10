/// Data buku disimpan dengan dua FK; nama kategori dan rak dibaca via JOIN.
class BookModel {
  final String? id;
  final String bookCode;
  final String title;
  final String author;
  final String publisher;
  final int publicationYear;
  final String categoryId;
  final String rackId;
  final String categoryName;
  final String rackCode;
  final String rackLocationName;
  final int stock;

  const BookModel({
    this.id,
    required this.bookCode,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.categoryId,
    required this.rackId,
    this.categoryName = '',
    this.rackCode = '',
    this.rackLocationName = '',
    required this.stock,
  });

  // Kompatibilitas tampilan lama (bukan kolom database).
  String get category => categoryName;
  String get rackLocation => rackCode.isEmpty
      ? rackLocationName
      : rackLocationName.isEmpty ? rackCode : '$rackCode - $rackLocationName';
  bool get isAvailable => stock > 0;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'];
    final rack = json['racks'];
    if (category is! Map || rack is! Map) {
      throw const FormatException('Buku belum memiliki data kategori/rak hasil JOIN.');
    }
    return BookModel(
      id: json['id'] as String?,
      bookCode: json['book_code'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String,
      publicationYear: (json['publication_year'] as num).toInt(),
      categoryId: json['category_id'] as String,
      rackId: json['rack_id'] as String,
      categoryName: category['name'] as String,
      rackCode: rack['rack_code'] as String,
      rackLocationName: rack['location'] as String,
      stock: (json['stock'] as num).toInt(),
    );
  }

  /// HANYA field database books; tidak mengirim atribut hasil JOIN.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'book_code': bookCode,
    'title': title,
    'author': author,
    'publisher': publisher,
    'publication_year': publicationYear,
    'category_id': categoryId,
    'rack_id': rackId,
    'stock': stock,
  };

  BookModel copyWith({
    String? id,
    String? bookCode,
    String? title,
    String? author,
    String? publisher,
    int? publicationYear,
    String? categoryId,
    String? rackId,
    String? categoryName,
    String? rackCode,
    String? rackLocationName,
    int? stock,
  }) => BookModel(
    id: id ?? this.id,
    bookCode: bookCode ?? this.bookCode,
    title: title ?? this.title,
    author: author ?? this.author,
    publisher: publisher ?? this.publisher,
    publicationYear: publicationYear ?? this.publicationYear,
    categoryId: categoryId ?? this.categoryId,
    rackId: rackId ?? this.rackId,
    categoryName: categoryName ?? this.categoryName,
    rackCode: rackCode ?? this.rackCode,
    rackLocationName: rackLocationName ?? this.rackLocationName,
    stock: stock ?? this.stock,
  );
}