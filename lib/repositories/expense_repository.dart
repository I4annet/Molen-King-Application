import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService service;

  ExpenseRepository({required this.service});

  Future<List<ExpenseModel>> getExpenses() {
    return service.getExpenses();
  }

  Future<void> addExpense({
    required String cashierId,
    required String cashierName,
    required double amount,
    required String description,
  }) {
    return service.addExpense(
      cashierId: cashierId,
      cashierName: cashierName,
      amount: amount,
      description: description,
    );
  }
}
