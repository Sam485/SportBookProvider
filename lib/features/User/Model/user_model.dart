class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role;
  final bool isVerified;
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? false,
    );
  }
}
