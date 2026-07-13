import 'package:molen_king_application/models/transaction_model.dart';
import 'package:molen_king_application/services/transaction_service.dart';

class TransactionRepository {
  final TransactionService service;

  TransactionRepository({required this.service});

  // ==========================
  // GET
  // ==========================
  Future<List<TransactionModel>> getTransactions() {
    return service.getTransactions();
  }

  // ==========================
  // CREATE
  // ==========================
  Future<void> createTransaction({
    required String cashierId,
    required String cashierName,
    required List<TransactionItem> items,
  }) {
    return service.createTransaction(
      cashierId: cashierId,
      cashierName: cashierName,
      items: items,
    );
  }

  // ==========================
  // DELETE
  // ==========================
  Future<void> deleteTransaction(String id) {
    return service.deleteTransaction(id);
  }
}
