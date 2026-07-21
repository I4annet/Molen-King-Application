import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/expense_model.dart';

class ReportService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ==================================
  // GET TRANSACTIONS IN PERIOD
  // ==================================
  Future<List<TransactionModel>> getTransactionsForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final response = await supabase
        .from('transactions')
        .select('*, transaction_items(*)')
        .gte('created_at', start.toUtc().toIso8601String())
        .lte('created_at', end.toUtc().toIso8601String())
        .order('created_at', ascending: false);

    return response
        .map<TransactionModel>((json) => TransactionModel.fromJson(
              json,
              json['transaction_items'] as List<dynamic>?,
            ))
        .toList();
  }

  // ==================================
  // GET EXPENSES IN PERIOD
  // ==================================
  Future<List<ExpenseModel>> getExpensesForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final response = await supabase
        .from('expenses')
        .select()
        .gte('created_at', start.toUtc().toIso8601String())
        .lte('created_at', end.toUtc().toIso8601String())
        .order('created_at', ascending: false);

    return response
        .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
        .toList();
  }
}
