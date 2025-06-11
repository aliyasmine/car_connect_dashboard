class UserModel {
  final int id;
  final String phone;
  final String? idImageUrl;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.phone,
    this.idImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      idImageUrl: json['idImageUrl'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
} 