import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository repository;

  AttendanceProvider({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  List<AttendanceModel> _attendanceLogs = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AttendanceModel> get attendanceLogs => _attendanceLogs;

  Future<void> loadAttendanceLogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendanceLogs = await repository.getAttendanceLogs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn({
    required String userId,
    required String userName,
    required String status,
    String? reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.checkIn(
        userId: userId,
        userName: userName,
        status: status,
        reason: reason,
      );
      await loadAttendanceLogs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut({required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.checkOut(userId: userId);
      await loadAttendanceLogs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
