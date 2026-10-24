class CategoryRackModel {
  final String id;
  final String categoryName;
  final String rackLocation;
  final DateTime createdAt;

  CategoryRackModel({
    required this.id,
    required this.categoryName,
    required this.rackLocation,
    required this.createdAt,
  });

  factory CategoryRackModel.fromJson(Map<String, dynamic> json) {
    return CategoryRackModel(
      id: json['id'],
      categoryName: json['category_name'],
      rackLocation: json['rack_location'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'rack_location': rackLocation,
    };
  }
}