class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role;
  final double? lat;
  final double? lng;
  final String? location;
  final bool isVerified;
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    this.lat,
    this.lng,
    this.location,
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
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      location: json['location'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? false,
    );
  }
}
