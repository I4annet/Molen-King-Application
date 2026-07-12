import 'package:molen_king_application/models/stock_model.dart';
import 'package:molen_king_application/services/stock_service.dart';

class StockRepository {
  final StockService service;

  StockRepository({required this.service});

  Future<List<StockModel>> getStocks() {
    return service.getStocks();
  }

  Future<void> updateStock({
    required String flavor,
    required int amountChange,
  }) {
    return service.updateStock(flavor: flavor, amountChange: amountChange);
  }

  Future<void> resetStock(String flavor) {
    return service.resetStock(flavor);
  }
}
