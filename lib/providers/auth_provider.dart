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
