class TransactionItem {
  final String flavor;
  final int quantity;
  final double price;

  TransactionItem({
    required this.flavor,
    required this.quantity,
    required this.price,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      flavor: json['flavor'] as String,
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flavor': flavor,
      'quantity': quantity,
      'price': price,
    };
  }
}

class TransactionModel {
  final String id;
  final String cashierId;
  final String cashierName;
  final double totalAmount;
  final DateTime createdAt;
  final List<TransactionItem> items;

  TransactionModel({
    required this.id,
    required this.cashierId,
    required this.cashierName,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, [List<dynamic>? itemsJson]) {
    final List<TransactionItem> parsedItems = [];
    if (itemsJson != null) {
      for (var item in itemsJson) {
        parsedItems.add(TransactionItem.fromJson(item as Map<String, dynamic>));
      }
    }
    return TransactionModel(
      id: json['id'] as String,
      cashierId: json['cashier_id'] as String? ?? '',
      cashierName: json['cashier_name'] as String? ?? 'Kasir',
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
