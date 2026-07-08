class AttendanceModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // 'present', 'sick', 'leave'
  final String? reason;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.reason,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Karyawan',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      status: json['status'] as String? ?? 'present',
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status,
      'reason': reason,
    };
  }
}
