import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_model.dart';

class StockService {
  final SupabaseClient supabase = Supabase.instance.client;

  // =====================
  // GET ALL STOCKS
  // =====================
  Future<List<StockModel>> getStocks() async {
    final response = await supabase.from('stocks').select().order('flavor');

    return response
        .map<StockModel>((json) => StockModel.fromJson(json))
        .toList();
  }

  // =====================
  // UPDATE STOCK
  // =====================
  Future<void> updateStock({
    required String flavor,
    required int amountChange,
  }) async {
    final stock = await supabase
        .from('stocks')
        .select()
        .eq('flavor', flavor)
        .single();

    final currentQty = stock['quantity'] as int;

    await supabase
        .from('stocks')
        .update({
          'quantity': currentQty + amountChange,
          'last_updated': DateTime.now().toIso8601String(),
        })
        .eq('flavor', flavor);
  }

  // =====================
  // RESET STOCK
  // =====================
  Future<void> resetStock(String flavor) async {
    await supabase
        .from('stocks')
        .update({
          'quantity': 0,
          'last_updated': DateTime.now().toIso8601String(),
        })
        .eq('flavor', flavor);
  }
}
