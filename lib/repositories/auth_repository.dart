import 'package:molen_king_application/services/profile_service.dart';
import 'package:molen_king_application/services/auth_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final AuthService authService;
  final ProfileService profileService;

  AuthRepository({required this.authService, required this.profileService});

  Future<List<UserModel>> getUsers() {
    return authService.getUsers();
  }

  Future<UserModel?> getUserProfile(String id) {
    return authService.getUserProfile(id);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String origin,
    required String role,
  }) {
    return authService.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      origin: origin,
      role: role,
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return authService.login(email: email, password: password);
  }

  Future<void> logout() async {
    await authService.logout();
  }

  Future<void> deleteUser(String id) {
    return profileService.deleteProfile(id);
  }
}
