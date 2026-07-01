import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/User/Model/login_reponse.dart';
import 'package:flutter_application_1/features/User/Model/login_request.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Model/user_model.dart';
import 'package:flutter_application_1/features/User/Repository/user_respository.dart';
import 'package:flutter_application_1/features/User/Service/user_service.dart';

class UserServiceImp extends ChangeNotifier implements UserService {
  final UserRespository userRepository;

  bool _isLoading = false;
  String _error = '';
  LoginResponse? _currentUser; // Optional: if you want to track current user

  @override
  bool get isLoading => _isLoading;
  @override
  String get error => _error;
  @override
  UserModel? get currentUser => _currentUser!.user;

  UserServiceImp(this.userRepository);

  @override
  Future<LoginResponse> loginUser(LoginRequest login) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userRepository.login(login);
      _currentUser = response;
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
      final response = await userRepository.registerUser(register);
      _currentUser = response;
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

  // Optional: Add a method to clear user state
  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }

  // Optional: Add a method to refresh user data
  Future<LoginResponse> refreshUser() async {
    if (_currentUser != null) {
      // You might want to fetch fresh user data here
      // For example: return await userRepository.getProfile();
    }
    return _currentUser!;
  }
}
