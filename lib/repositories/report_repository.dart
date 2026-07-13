import '../models/transaction_model.dart';
import '../models/expense_model.dart';
import '../services/report_service.dart';

class ReportRepository {
  final ReportService service;

  ReportRepository({required this.service});

  Future<List<TransactionModel>> getTransactionsForPeriod(
    DateTime start,
    DateTime end,
  ) {
    return service.getTransactionsForPeriod(start, end);
  }

  Future<List<ExpenseModel>> getExpensesForPeriod(
    DateTime start,
    DateTime end,
  ) {
    return service.getExpensesForPeriod(start, end);
  }
}
