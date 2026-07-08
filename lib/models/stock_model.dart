class StockModel {
  final String flavor; // 'keju', 'ori', 'coklat'
  final int quantity;
  final DateTime lastUpdated;

  StockModel({
    required this.flavor,
    required this.quantity,
    required this.lastUpdated,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      flavor: json['flavor'] as String,
      quantity: json['quantity'] as int? ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flavor': flavor,
      'quantity': quantity,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  StockModel copyWith({
    String? flavor,
    int? quantity,
    DateTime? lastUpdated,
  }) {
    return StockModel(
      flavor: flavor ?? this.flavor,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
