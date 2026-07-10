import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/User/Model/login_reponse.dart';
import 'package:flutter_application_1/features/User/Model/login_request.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Model/update_password_model.dart';
import 'package:flutter_application_1/features/User/Model/update_user_model.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';
import 'package:flutter_application_1/features/User/Repository/user_respository.dart';
import 'package:flutter_application_1/features/User/Service/user_service.dart';

class UserServiceImp extends ChangeNotifier implements UserService {
  final UserRespository userApiRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String _error = '';

  @override
  UserModel? get currentUser => _currentUser;
  @override
  bool get isLoading => _isLoading;
  @override
  String get error => _error;

  UserServiceImp(this.userApiRepository);

  @override
  Future<LoginResponse> loginUser(LoginRequest login) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userApiRepository.login(login);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<LoginResponse> registerUser(RegisterUserModel register) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userApiRepository.registerUser(register);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await userApiRepository.getUserProfile();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateUserModel data) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await userApiRepository.updateUserProfile(data);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<UserModel> updateAvatar(File file) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await userApiRepository.uploadAvatar(file);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> changePassword(UpdatePasswordModel request) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await userApiRepository.updateUserPassword(request);
      _isLoading = false;
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ✅ NEW: Refresh current user data from server
  @override
  Future<UserModel> refreshCurrentUser() async {
    try {
      final user = await getProfile();
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void updateUserLocally(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  @override
  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
