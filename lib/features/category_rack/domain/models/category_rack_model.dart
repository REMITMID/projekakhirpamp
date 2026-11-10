/// Referensi pasangan kategori-rak yang boleh dipilih ketika menyimpan buku.
class CategoryRackModel {
  final String id;
  final String categoryId;
  final String rackId;

  const CategoryRackModel({
    required this.id,
    required this.categoryId,
    required this.rackId,
  });

  factory CategoryRackModel.fromJson(Map<String, dynamic> json) =>
      CategoryRackModel(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        rackId: json['rack_id'] as String,
      );
}