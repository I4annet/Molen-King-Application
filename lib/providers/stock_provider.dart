import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../repositories/stock_repository.dart';

class StockProvider extends ChangeNotifier {
  final StockRepository repository;

  StockProvider({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;

  List<StockModel> _stockList = [];

  final Map<String, double> _molenPrices = {
    'keju': 1000,
    'ori': 1000,
    'coklat': 1000,
  };

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<StockModel> get stockList => _stockList;

  Map<String, double> get molenPrices => _molenPrices;

  Map<String, int> get stocks {
    return {for (final stock in _stockList) stock.flavor: stock.quantity};
  }

  Future<void> loadStocks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stockList = await repository.getStocks();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStock({
    required String flavor,
    required int amountChange,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateStock(flavor: flavor, amountChange: amountChange);

      await loadStocks();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetStock(String flavor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.resetStock(flavor);

      await loadStocks();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
