import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../services/supabase_service.dart';

class FinanceProvider with ChangeNotifier {
  final SupabaseService _service;

  List<TransactionModel> _transactions = [];
  GoalModel? _currentGoal;
  bool _isLoading = false;
  String? _error;

  FinanceProvider({SupabaseService? service})
    : _service = service ?? SupabaseService() {
    loadData();
  }

  List<TransactionModel> get transactions => _transactions;
  GoalModel? get currentGoal => _currentGoal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get currentBalance {
    return totalIncome - totalExpense;
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> categories = {};
    for (var t in _transactions.where((t) => t.type == 'expense')) {
      categories[t.category] = (categories[t.category] ?? 0.0) + t.amount;
    }
    return categories;
  }

  String get highestSpendingCategory {
    final categories = expensesByCategory;
    if (categories.isEmpty) return 'No Data';
    return categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> loadData() async {
    _setLoading(true);
    _error = null;
    try {
      final txns = await _service.getTransactions();
      _transactions = txns;

      final now = DateTime.now();
      _currentGoal = await _service.getMonthlyGoal(
        DateTime(now.year, now.month, 1),
      );
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addTransaction({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? notes,
  }) async {
    _error = null;
    try {
      final txn = TransactionModel(
        id: const Uuid().v4(),
        amount: amount,
        type: type,
        category: category,
        date: date,
        notes: notes,
      );
      final newTxn = await _service.addTransaction(txn);
      _transactions.insert(0, newTxn); // Prepend locally
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? notes,
  }) async {
    _error = null;
    try {
      final txn = TransactionModel(
        id: id,
        amount: amount,
        type: type,
        category: category,
        date: date,
        notes: notes,
      );
      final updatedTxn = await _service.updateTransaction(txn);
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _transactions[index] = updatedTxn;
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setMonthlyGoal(double amount) async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    try {
      final goal = GoalModel(
        id: _currentGoal?.id ?? const Uuid().v4(),
        targetAmount: amount,
        month: month,
      );
      final newGoal = await _service.saveMonthlyGoal(goal);
      _currentGoal = newGoal;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
