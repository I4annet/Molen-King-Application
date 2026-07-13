import 'package:molen_king_application/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String origin, // asal kota
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'phone': phone,
        'origin': origin,
        'role': role,
        'is_active': true,
      });
    }

    return response;
  }

  Future<void> logout() {
    return _supabase.auth.signOut();
  }

  Session? get currentSession => _supabase.auth.currentSession;

  User? get currentUser => _supabase.auth.currentUser;

  Future<List<UserModel>> getUsers() async {
    final response = await _supabase.from('profiles').select().order('name');

    return response.map<UserModel>((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel?> getUserProfile(String id) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;

    return UserModel.fromJson(data);
  }
}
