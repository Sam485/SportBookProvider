class UpdatePasswordModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  UpdatePasswordModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory UpdatePasswordModel.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordModel(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
