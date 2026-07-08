class ExpenseModel {
  final String id;
  final String cashierId;
  final String cashierName;
  final double amount;
  final String description; // komentar pengeluaran
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.cashierId,
    required this.cashierName,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      cashierId: json['cashier_id'] as String? ?? '',
      cashierName: json['cashier_name'] as String? ?? 'Kasir',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'amount': amount,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
