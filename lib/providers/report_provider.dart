import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/expense_model.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository repository;

  ReportProvider({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> _transactions = [];
  List<ExpenseModel> _expenses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransactionModel> get transactions => _transactions;
  List<ExpenseModel> get expenses => _expenses;

  Future<void> loadReportData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final start = DateTime(2000, 1, 1);
      final end = DateTime.now().add(const Duration(days: 365));

      _transactions = await repository.getTransactionsForPeriod(start, end);
      _expenses = await repository.getExpensesForPeriod(start, end);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- REPORT METRICS ---

  int getMolenSoldQuantity(String flavor) {
    int total = 0;
    for (var tx in _transactions) {
      for (var item in tx.items) {
        if (item.flavor == flavor) {
          total += item.quantity;
        }
      }
    }
    return total;
  }

  int getTotalMolenSold() {
    int total = 0;
    for (var tx in _transactions) {
      for (var item in tx.items) {
        total += item.quantity;
      }
    }
    return total;
  }

  List<TransactionModel> _getTransactionsInPeriod(DateTime start, DateTime end) {
    return _transactions.where((tx) {
      return tx.createdAt.isAfter(start) && tx.createdAt.isBefore(end);
    }).toList();
  }

  List<ExpenseModel> _getExpensesInPeriod(DateTime start, DateTime end) {
    return _expenses.where((ex) {
      return ex.createdAt.isAfter(start) && ex.createdAt.isBefore(end);
    }).toList();
  }

  Map<String, double> getStatsForPeriod(String period) {
    final now = DateTime.now();
    DateTime start;

    switch (period) {
      case 'daily':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'monthly':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    final end = now.add(const Duration(seconds: 1));
    final txs = _getTransactionsInPeriod(start, end);
    final exps = _getExpensesInPeriod(start, end);

    double sales = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
    double expensesTotal = exps.fold<double>(0, (sum, ex) => sum + ex.amount);
    int itemsCount = 0;

    for (var tx in txs) {
      for (var item in tx.items) {
        itemsCount += item.quantity;
      }
    }

    return {
      'revenue': sales,
      'expenses': expensesTotal,
      'profit': sales - expensesTotal,
      'qty_sold': itemsCount.toDouble(),
    };
  }

  List<MapEntry<String, double>> getChartDataForPeriod(String period) {
    final now = DateTime.now();
    final List<MapEntry<String, double>> data = [];

    if (period == 'daily') {
      for (int i = 6; i >= 0; i--) {
        final time = now.subtract(Duration(hours: i * 2));
        final start = time.subtract(const Duration(hours: 2));
        final txs = _getTransactionsInPeriod(start, time);
        final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
        final label = "${time.hour.toString().padLeft(2, '0')}:00";
        data.add(MapEntry(label, revenue));
      }
    } else if (period == 'weekly') {
      final List<String> days = [
        'Sen',
        'Sel',
        'Rab',
        'Kam',
        'Jum',
        'Sab',
        'Min',
      ];
      final weekday = now.weekday;
      for (int i = 1; i <= 7; i++) {
        final targetDate = now.subtract(Duration(days: weekday - i));
        final start = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );
        final end = start.add(const Duration(days: 1));
        final txs = _getTransactionsInPeriod(start, end);
        final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
        data.add(MapEntry(days[i - 1], revenue));
      }
    } else if (period == 'monthly') {
      for (int i = 3; i >= 0; i--) {
        final start = now.subtract(Duration(days: (i + 1) * 7));
        final end = now.subtract(Duration(days: i * 7));
        final txs = _getTransactionsInPeriod(start, end);
        final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
        data.add(MapEntry("Wk ${4 - i}", revenue));
      }
    } else if (period == 'yearly') {
      final List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      for (int i = 0; i < 12; i++) {
        final monthIndex = (now.month - 11 + i) % 12;
        final yearOffset = (now.month - 11 + i) <= 0 ? -1 : 0;
        final targetYear = now.year + yearOffset;
        final start = DateTime(targetYear, monthIndex + 1, 1);
        final end = DateTime(
          targetYear,
          monthIndex + 2,
          1,
        ).subtract(const Duration(seconds: 1));

        final txs = _getTransactionsInPeriod(start, end);
        final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
        data.add(MapEntry(months[monthIndex], revenue));
      }
    }

    return data;
  }
}
