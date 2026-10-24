class MemberModel {
  final String? id;
  final String memberNumber;
  final String name;
  final String email;
  final String phone;
  final String address;

  const MemberModel({
    this.id,
    required this.memberNumber,
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      memberNumber: json['member_number'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'member_number': memberNumber.trim(),
    'name': name.trim(),
    'email': email.trim().toLowerCase(),
    'phone': phone.trim(),
    'address': address.trim(),
  };
}
