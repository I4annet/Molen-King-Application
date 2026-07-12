import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository});

  bool isLoggingIn = false;

  bool isRegistering = false;

  String? errorMessage;

  UserModel? currentUser;
}
