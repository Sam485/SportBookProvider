class UserDto {
  final int id;
  final String fullName;
  final String role;

  UserDto({required this.id, required this.fullName, required this.role});

  factory UserDto.fromjson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 0,
      role: json['role'] ?? '',
    );
  }

  UserDto copyWith(int? id, String? fullName, String? role) {
    return UserDto(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
    );
  }
}
