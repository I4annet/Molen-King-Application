import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:molen_king_application/services/supabase_config.dart';

void main() {
  test('Test Supabase Connection and Query', () async {
    print('Initializing Supabase...');
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      print('Supabase initialized successfully.');
      
      final client = Supabase.instance.client;
      
      print('Testing query to profiles...');
      final profiles = await client.from('profiles').select().limit(5);
      print('Profiles fetched: $profiles');
      
      print('Testing query to attendance_logs...');
      final logs = await client.from('attendance_logs').select().limit(5);
      print('Attendance logs fetched: $logs');

    } catch (e, stack) {
      print('ERROR occurred: $e');
      print('STACKTRACE:\n$stack');
    }
  });
}
