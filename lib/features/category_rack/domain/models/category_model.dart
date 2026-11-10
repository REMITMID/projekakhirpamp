class CategoryModel {
  final String id;
  final String name;
  final String? description;

  const CategoryModel({required this.id, required this.name, this.description});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}