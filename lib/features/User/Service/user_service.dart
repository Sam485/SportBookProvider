import 'package:flutter_application_1/features/User/Model/login_reponse.dart';
import 'package:flutter_application_1/features/User/Model/login_request.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';

abstract class UserService {
  Future<LoginResponse> registerUser(RegisterUserModel register);
  Future<LoginResponse> loginUser(LoginRequest login);
    // State getters
  UserModel? get currentUser;
  bool get isLoading;
  String get error;

  void addListener(void Function() onUserServiceChanged) {}

  void removeListener(void Function() onUserServiceChanged) {}

}
