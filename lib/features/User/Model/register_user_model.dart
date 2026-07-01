class RegisterUserModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;

  RegisterUserModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.role = 'partner',
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'role': role,
    };
  }

  RegisterUserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    String? role,
  }) {
    return RegisterUserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
