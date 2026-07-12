import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final SupabaseClient supabase = Supabase.instance.client;

  // =====================
  // GET ATTENDANCE LOGS
  // =====================
  Future<List<AttendanceModel>> getAttendanceLogs() async {
    final response = await supabase
        .from('attendance_logs')
        .select()
        .order('check_in_time', ascending: false);

    return response
        .map<AttendanceModel>((json) => AttendanceModel.fromJson(json))
        .toList();
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

    await supabase.from('attendance_logs').insert(logJson);

    await supabase
        .from('profiles')
        .update({
          'is_active': status == 'present',
          'last_check_in': now.toIso8601String(),
          'last_check_out': null,
        })
        .eq('id', userId);
  }

  // =====================
  // CHECK OUT
  // =====================
  Future<void> checkOut({required String userId}) async {
    final now = DateTime.now();

    final lastLogRes = await supabase
        .from('attendance_logs')
        .select()
        .eq('user_id', userId)
        .isFilter('check_out_time', null)
        .order('check_in_time', ascending: false)
        .limit(1)
        .maybeSingle();

    if (lastLogRes != null) {
      final logId = lastLogRes['id'] as String;
      await supabase
          .from('attendance_logs')
          .update({'check_out_time': now.toIso8601String()})
          .eq('id', logId);
    }

    await supabase
        .from('profiles')
        .update({
          'is_active': false,
          'last_check_out': now.toIso8601String(),
        })
        .eq('id', userId);
  }
}
