import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository repository;

  ExpenseProvider({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  List<ExpenseModel> _expenses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ExpenseModel> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await repository.getExpenses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense({
    required String cashierId,
    required String cashierName,
    required double amount,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.addExpense(
        cashierId: cashierId,
        cashierName: cashierName,
        amount: amount,
        description: description,
      );
      await loadExpenses();
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
