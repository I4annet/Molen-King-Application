import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceRepository {
  final AttendanceService service;

  AttendanceRepository({required this.service});

  Future<List<AttendanceModel>> getAttendanceLogs() {
    return service.getAttendanceLogs();
  }

  Future<void> checkIn({
    required String userId,
    required String userName,
    required String status,
    String? reason,
  }) {
    return service.checkIn(
      userId: userId,
      userName: userName,
      status: status,
      reason: reason,
    );
  }

  Future<void> checkOut({required String userId}) {
    return service.checkOut(userId: userId);
  }
}
