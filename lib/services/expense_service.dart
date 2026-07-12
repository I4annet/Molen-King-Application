import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // =====================
  // GET ALL EXPENSES
  // =====================
  Future<List<ExpenseModel>> getExpenses() async {
    final response = await supabase
        .from('expenses')
        .select()
        .order('created_at', ascending: false);

    return response
        .map<ExpenseModel>((json) => ExpenseModel.fromJson(json))
        .toList();
  }

  // =====================
  // ADD EXPENSE
  // =====================
  Future<void> addExpense({
    required String cashierId,
    required String cashierName,
    required double amount,
    required String description,
  }) async {
    await supabase.from('expenses').insert({
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'amount': amount,
      'description': description,
    });
  }
}
