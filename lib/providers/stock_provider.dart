import 'package:flutter/material.dart';
import 'package:molen_king_application/models/stock_model.dart';
import 'package:molen_king_application/repositories/stock_repository.dart';

class StockProvider extends ChangeNotifier {
  final StockRepository repository;

  StockProvider({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;

  List<StockModel> _stocks = [];

  // ======================
  // GETTERS
  // ======================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<StockModel> get stocks => _stocks;

  // ======================
  // LOAD STOCK
  // ======================

  Future<void> loadStocks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stocks = await repository.getStocks();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ======================
  // UPDATE STOCK
  // ======================

  Future<bool> updateStock({
    required String flavor,
    required int amountChange,
  }) async {
    _isLoading = true;
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

  // ======================
  // RESET STOCK
  // ======================

  Future<bool> resetStock(String flavor) async {
    _isLoading = true;
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
