class RackModel {
  final String id;
  final String rackCode;
  final String location;

  const RackModel({
    required this.id,
    required this.rackCode,
    required this.location,
  });

  String get displayName => '$rackCode - $location';

  factory RackModel.fromJson(Map<String, dynamic> json) => RackModel(
    id: json['id'] as String,
    rackCode: json['rack_code'] as String,
    location: json['location'] as String,
  );
}