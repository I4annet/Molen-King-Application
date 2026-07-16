import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final SupabaseClient supabase = Supabase.instance.client;

  // =====================
  // GET ATTENDANCE LOGS
  // =====================
  Future<List<AttendanceModel>> getAttendanceLogs() async {
    try {
      print('DEBUG [AttendanceService]: Mengambil data dari attendance_logs...');
      final response = await supabase
          .from('attendance_logs')
          .select()
          .order('check_in_time', ascending: false)
          .timeout(const Duration(seconds: 15));
      print('DEBUG [AttendanceService]: Berhasil mengambil ${response.length} log.');

      return response
          .map<AttendanceModel>((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('DEBUG [AttendanceService]: Gagal mengambil data attendance_logs: $e');
      rethrow;
    }
  }

  // =====================
  // CHECK IN
  // =====================
  Future<void> checkIn({
    required String userId,
    required String userName,
    required String status,
    String? reason,
  }) async {
    final now = DateTime.now();
    final log = AttendanceModel(
      id: '',
      userId: userId,
      userName: userName,
      date: now,
      checkInTime: now,
      status: status,
      reason: reason,
    );

    final logJson = log.toJson();
    logJson.remove('id'); // let Supabase generate UUID

    try {
      print('DEBUG [AttendanceService]: Memulai insert ke attendance_logs: $logJson...');
      await supabase
          .from('attendance_logs')
          .insert(logJson)
          .timeout(const Duration(seconds: 15));
      print('DEBUG [AttendanceService]: Insert ke attendance_logs sukses.');
    } catch (e) {
      print('DEBUG [AttendanceService]: Gagal insert ke attendance_logs: $e');
      rethrow;
    }

    try {
      print('DEBUG [AttendanceService]: Mengupdate profiles is_active dan last_check_in untuk user $userId...');
      await supabase
          .from('profiles')
          .update({
            'is_active': status == 'present',
            'last_check_in': now.toIso8601String(),
            'last_check_out': null,
          })
          .eq('id', userId)
          .timeout(const Duration(seconds: 15));
      print('DEBUG [AttendanceService]: Update profiles sukses.');
    } catch (e) {
      print('DEBUG [AttendanceService]: Gagal update profiles: $e');
      rethrow;
    }
  }

  // =====================
  // CHECK OUT
  // =====================
  Future<void> checkOut({required String userId}) async {
    final now = DateTime.now();

    try {
      print('DEBUG [AttendanceService]: Mencari log check-in aktif untuk user $userId...');
      final lastLogRes = await supabase
          .from('attendance_logs')
          .select()
          .eq('user_id', userId)
          .isFilter('check_out_time', null)
          .order('check_in_time', ascending: false)
          .limit(1)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (lastLogRes != null) {
        final logId = lastLogRes['id'] as String;
        print('DEBUG [AttendanceService]: Mengupdate check_out_time untuk log $logId...');
        await supabase
            .from('attendance_logs')
            .update({'check_out_time': now.toIso8601String()})
            .eq('id', logId)
            .timeout(const Duration(seconds: 15));
        print('DEBUG [AttendanceService]: Update check_out_time sukses.');
      } else {
        print('DEBUG [AttendanceService]: Tidak ditemukan log check-in aktif.');
      }
    } catch (e) {
      print('DEBUG [AttendanceService]: Gagal update check_out_time log: $e');
      rethrow;
    }

    try {
      print('DEBUG [AttendanceService]: Mengupdate profiles is_active = false untuk user $userId...');
      await supabase
          .from('profiles')
          .update({
            'is_active': false,
            'last_check_out': now.toIso8601String(),
          })
          .eq('id', userId)
          .timeout(const Duration(seconds: 15));
      print('DEBUG [AttendanceService]: Update profiles checkout selesai.');
    } catch (e) {
      print('DEBUG [AttendanceService]: Gagal update profiles checkout: $e');
      rethrow;
    }
  }
}
