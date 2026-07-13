import 'package:flutter/foundation.dart';
import 'package:molen_king_application/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

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
    // Kirim metadata saat signUp agar role tersimpan di Supabase auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role, 'phone': phone, 'origin': origin},
    );

    if (response.user != null) {
      try {
        // Jika tidak ada session (email confirmation diperlukan),
        // coba login dulu untuk mendapatkan session agar bisa insert profile
        if (response.session == null) {
          debugPrint(
            'Email confirmation mungkin diperlukan. Mencoba insert profile...',
          );
        }

        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'origin': origin,
          'role': role,
          'is_active': true,
        });
        debugPrint(
          'Profile berhasil disimpan: id=${response.user!.id}, role=$role',
        );
      } catch (e) {
        debugPrint('Gagal menyimpan profile ke Supabase: $e');
        // Jangan rethrow — user sudah terdaftar di auth,
        // profile bisa dibuat saat login pertama kali
      }
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
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        debugPrint(
          'Profile tidak ditemukan untuk id=$id, mencoba membuat dari metadata...',
        );

        // Fallback: buat profile dari auth user metadata (disimpan saat signUp)
        final authUser = _supabase.auth.currentUser;
        if (authUser != null && authUser.id == id) {
          final meta = authUser.userMetadata ?? {};
          final name = meta['name'] as String? ?? authUser.email ?? '';
          final role = meta['role'] as String? ?? 'cashier';
          final email = authUser.email ?? '';
          final phone = meta['phone'] as String? ?? '';
          final origin = meta['origin'] as String? ?? '';

          // Coba simpan ke tabel profiles
          try {
            await _supabase.from('profiles').upsert({
              'id': id,
              'name': name,
              'email': email,
              'phone': phone,
              'origin': origin,
              'role': role,
              'is_active': true,
            });
            debugPrint('Profile dibuat dari metadata: name=$name, role=$role');
          } catch (insertErr) {
            debugPrint('Gagal menyimpan profile dari metadata: $insertErr');
          }

          return UserModel(
            id: id,
            name: name,
            email: email,
            phone: phone,
            origin: origin,
            role: role,
            isActive: true,
          );
        }

        return null;
      }

      final user = UserModel.fromJson(data);
      debugPrint(
        'Profile berhasil dimuat: name=${user.name}, role=${user.role}',
      );
      return user;
    } catch (e) {
      debugPrint('Error mengambil profile: $e');
      return null;
    }
  }
}
