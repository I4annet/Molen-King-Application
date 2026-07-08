class SupabaseConfig {
  // Masukkan kredensial Supabase Anda di sini.
  // Jika dibiarkan kosong, aplikasi otomatis berjalan dalam "Mode Simulasi" (Offline/Lokal)
  // sehingga dapat langsung diuji coba dengan lancar.
  static const String url = 'https://tkskzzwwzzgbloadraij.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRrc2t6end3enpnYmxvYWRyYWlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1MDkwNTksImV4cCI6MjA5ODA4NTA1OX0.B-FhT4V3okP_-gKVioqrYE8mRuuqME_TxqhSoiWGygg';

  static bool get isConfigured =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}
