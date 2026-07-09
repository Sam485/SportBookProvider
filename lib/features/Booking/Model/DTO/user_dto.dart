class UserDto {
  final int id;
  final String fullName;
  final String phone;
  final String email;

  UserDto({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  UserDto copywith(int? id, String? fullName, String? phone, String? email) {
    return UserDto(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
