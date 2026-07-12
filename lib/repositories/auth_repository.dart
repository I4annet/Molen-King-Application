import 'package:molen_king_application/services/profile_service.dart';
import 'package:molen_king_application/services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService authService;
  final ProfileService profileService;

  AuthRepository({required this.authService, required this.profileService});
  final authRepository = AuthRepository(
    authService: AuthService(),
    profileService: ProfileService(),
  );

  Future<List<UserModel>> getUsers() {
    return authService.getUsers();
  }
}
