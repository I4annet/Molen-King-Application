import 'package:flutter/material.dart';
import 'package:molen_king_application/models/transaction_model.dart';
import 'package:molen_king_application/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository repository;

  TransactionProvider({required this.repository});

  bool _isLoading = false;

  String? _errorMessage;

  List<TransactionModel> _transactions = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<TransactionModel> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await repository.getTransactions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction({
    required String cashierId,
    required String cashierName,
    required List<TransactionItem> items,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.createTransaction(
        cashierId: cashierId,
        cashierName: cashierName,
        items: items,
      );

      await loadTransactions();

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
