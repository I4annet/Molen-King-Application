import 'package:molen_king_application/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> createTransaction({
    required String cashierId,
    required String cashierName,
    required List<TransactionItem> items,
  }) async {
    try {
      final total = items.fold<double>(
        0,
        (sum, item) => sum + item.price * item.quantity,
      );

      final transaction = await supabase
          .from('transactions')
          .insert({
            'cashier_id': cashierId,
            'cashier_name': cashierName,
            'total_amount': total,
          })
          .select()
          .single();

      final transactionId = transaction['id'];

      for (final item in items) {
        await supabase.from('transaction_items').insert({
          'transaction_id': transactionId,
          'flavor': item.flavor,
          'quantity': item.quantity,
          'price': item.price,
        });
      }
    } catch (e) {
      throw Exception("Gagal membuat transaksi: $e");
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    final response = await supabase
        .from('transactions')
        .select('''
        *,
        transaction_items(*)
      ''')
        .order('created_at', ascending: false);

    return response
        .map<TransactionModel>((json) => TransactionModel.fromJson(json))
        .toList();
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await supabase
          .from('transaction_items')
          .delete()
          .eq('transaction_id', transactionId);

      await supabase.from('transactions').delete().eq('id', transactionId);
    } catch (e) {
      throw Exception("Gagal menghapus transaksi: $e");
    }
  }
}
