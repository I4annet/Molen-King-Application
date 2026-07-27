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
        _errorMessage = "Registrasi gagal.";
        return false;
      }

      return true;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('user already exists') || errStr.contains('already registered') || errStr.contains('conflict')) {
        _errorMessage = "Email sudah terdaftar. Silakan gunakan email lain.";
      } else if (errStr.contains('network') || errStr.contains('socketexception') || errStr.contains('failed host lookup')) {
        _errorMessage = "Gagal terhubung ke server. Periksa koneksi internet Anda.";
      } else if (errStr.contains('weak password') || errStr.contains('password should be at least')) {
        _errorMessage = "Kata sandi terlalu lemah. Gunakan minimal 6 karakter.";
      } else if (errStr.contains('invalid email')) {
        _errorMessage = "Format alamat email tidak valid.";
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
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
        _errorMessage = "Email tidak terdaftar atau kata sandi salah.";
        return false;
      }

      _currentUser = await repository.getUserProfile(response.user!.id);

      if (_currentUser == null) {
        _errorMessage = "Profil pengguna tidak ditemukan.";
        return false;
      }

      return true;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('invalid login credentials') || errStr.contains('invalid credentials') || errStr.contains('invalid email')) {
        _errorMessage = "Email tidak terdaftar atau kata sandi salah.";
      } else if (errStr.contains('email not confirmed')) {
        _errorMessage = "Email belum dikonfirmasi. Silakan periksa inbox Anda.";
      } else if (errStr.contains('network') || errStr.contains('socketexception') || errStr.contains('failed host lookup')) {
        _errorMessage = "Gagal terhubung ke server. Periksa koneksi internet Anda.";
      } else if (errStr.contains('too many requests')) {
        _errorMessage = "Terlalu banyak percobaan masuk. Silakan coba beberapa saat lagi.";
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
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

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await repository.getUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteUser(id);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
