import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/User/Model/login_reponse.dart';
import 'package:flutter_application_1/features/User/Model/login_request.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Model/update_password_model.dart';
import 'package:flutter_application_1/features/User/Model/update_user_model.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';

abstract class UserService extends ChangeNotifier {
  Future<LoginResponse> loginUser(LoginRequest login);
  Future<LoginResponse> registerUser(RegisterUserModel register);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateUserModel data);
  Future<UserModel> updateAvatar(File file);

  // Change Password
  Future<void> changePassword(UpdatePasswordModel request);

  // Refresh current user
  Future<UserModel> refreshCurrentUser();

  // State getters
  UserModel? get currentUser;
  bool get isLoading;
  String get error;

  void updateUserLocally(UserModel user);
  void clearUser();
}
