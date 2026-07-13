import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository});

  bool _isLoading = false;

  String? _errorMessage;

  UserModel? _currentUser;

  List<UserModel> _users = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UserModel? get currentUser => _currentUser;

  List<UserModel> get users => _users;

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String origin,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        origin: origin,
        role: role,
      );

      if (response.user == null) {
        _errorMessage = "Registrasi gagal";
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.login(email: email, password: password);

      if (response.user == null) {
        _errorMessage = "Login gagal";
        return false;
      }

      _currentUser = await repository.getUserProfile(response.user!.id);

      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.logout();

    _currentUser = null;

    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    try {
      final updatedUser = await repository.getUserProfile(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to refresh current user: $e");
    }
  }
}
