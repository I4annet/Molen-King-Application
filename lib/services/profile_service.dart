import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> getProfile(String id) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;

    return UserModel.fromJson(data);
  }

  Future<void> createProfile(UserModel user) async {
    await _supabase.from('profiles').insert(user.toJson());
  }

  Future<void> updateProfile(UserModel user) async {
    await _supabase.from('profiles').update(user.toJson()).eq('id', user.id);
  }
}
