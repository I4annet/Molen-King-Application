class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String origin;
  final String role; // 'cashier' or 'admin'
  final bool isActive;
  final DateTime? lastCheckIn;
  final DateTime? lastCheckOut;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.origin, // asal kota
    required this.role,
    this.isActive = false,
    this.lastCheckIn,
    this.lastCheckOut,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      role: json['role'] as String? ?? 'cashier',
      isActive: json['is_active'] as bool? ?? false,
      lastCheckIn: json['last_check_in'] != null
          ? DateTime.parse(json['last_check_in'])
          : null,
      lastCheckOut: json['last_check_out'] != null
          ? DateTime.parse(json['last_check_out'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'origin': origin,
      'role': role,
      'is_active': isActive,
      'last_check_in': lastCheckIn?.toIso8601String(),
      'last_check_out': lastCheckOut?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? origin,
    String? role,
    bool? isActive,
    DateTime? lastCheckIn,
    DateTime? lastCheckOut,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      origin: origin ?? this.origin,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      lastCheckOut: lastCheckOut ?? this.lastCheckOut,
    );
  }
}
