import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../core/constants.dart';

class SupabaseService {
  final SupabaseClient? _client;
  final bool _isMock;

  final List<TransactionModel> _mockTransactions = [];
  final List<GoalModel> _mockGoals = [];
  bool _mockIsInitialized = false;

  SupabaseService()
    : _isMock = AppConstants.supabaseUrl.contains('placeholder'),
      _client = AppConstants.supabaseUrl.contains('placeholder')
          ? null
          : Supabase.instance.client;

  Future<void> _ensureMockInitialized() async {
    if (!_isMock || _mockIsInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    final cachedTransactions = prefs.getString('offline_transactions');
    if (cachedTransactions != null) {
      final List<dynamic> jsonList = jsonDecode(cachedTransactions);
      _mockTransactions.clear();
      _mockTransactions.addAll(
        jsonList.map((j) => TransactionModel.fromJson(j)),
      );
    } else {
      final now = DateTime.now();
      _mockTransactions.addAll([
        TransactionModel(
          id: const Uuid().v4(),
          amount: 3000.0,
          type: 'income',
          category: 'Salary',
          date: now.subtract(const Duration(days: 5)),
          notes: 'Monthly salary',
        ),
        TransactionModel(
          id: const Uuid().v4(),
          amount: 50.0,
          type: 'expense',
          category: 'Food',
          date: now.subtract(const Duration(days: 2)),
          notes: 'Groceries',
        ),
        TransactionModel(
          id: const Uuid().v4(),
          amount: 120.0,
          type: 'expense',
          category: 'Utilities',
          date: now.subtract(const Duration(days: 1)),
          notes: 'Electricity bill',
        ),
      ]);
    }

    final cachedGoals = prefs.getString('offline_goals');
    if (cachedGoals != null) {
      final List<dynamic> jsonList = jsonDecode(cachedGoals);
      _mockGoals.clear();
      _mockGoals.addAll(jsonList.map((j) => GoalModel.fromJson(j)));
    } else {
      final now = DateTime.now();
      _mockGoals.add(
        GoalModel(
          id: const Uuid().v4(),
          targetAmount: 500.0,
          month: DateTime(now.year, now.month, 1),
        ),
      );
    }

    _mockIsInitialized = true;
    _saveMockData();
  }

  Future<void> _saveMockData() async {
    if (!_isMock) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'offline_transactions',
      jsonEncode(_mockTransactions.map((t) => t.toJson()).toList()),
    );
    await prefs.setString(
      'offline_goals',
      jsonEncode(_mockGoals.map((g) => g.toJson()).toList()),
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    if (_isMock) {
      await _ensureMockInitialized();
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockTransactions.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } else {
      final data = await _client!
          .from('transactions')
          .select()
          .order('date', ascending: false);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    }
  }

  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    if (_isMock) {
      await _ensureMockInitialized();
      await Future.delayed(const Duration(milliseconds: 500));
      _mockTransactions.insert(0, transaction);
      await _saveMockData();
      return transaction;
    } else {
      final payload = transaction.toJson();
      payload['user_id'] = _client!.auth.currentUser!.id;
      final data = await _client!
          .from('transactions')
          .insert(payload)
          .select()
          .single();
      return TransactionModel.fromJson(data);
    }
  }

  Future<void> deleteTransaction(String id) async {
    if (_isMock) {
      await _ensureMockInitialized();
      await Future.delayed(const Duration(milliseconds: 300));
      _mockTransactions.removeWhere((t) => t.id == id);
      await _saveMockData();
    } else {
      await _client!.from('transactions').delete().eq('id', id);
    }
  }

  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    if (_isMock) {
      await _ensureMockInitialized();
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockTransactions.indexWhere((t) => t.id == transaction.id);
      if (index >= 0) {
        _mockTransactions[index] = transaction;
        await _saveMockData();
      }
      return transaction;
    } else {
      final payload = transaction.toJson();
      payload['user_id'] = _client!.auth.currentUser!.id;
      final data = await _client!
          .from('transactions')
          .update(payload)
          .eq('id', transaction.id)
          .select()
          .single();
      return TransactionModel.fromJson(data);
    }
  }

  Future<GoalModel?> getMonthlyGoal(DateTime month) async {
    final targetMonth = DateTime(month.year, month.month, 1);
    if (_isMock) {
      await _ensureMockInitialized();
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return _mockGoals.firstWhere((g) => g.month == targetMonth);
      } catch (_) {
        return null;
      }
    } else {
      final data = await _client!
          .from('goals')
          .select()
          .eq('month', targetMonth.toIso8601String())
          .maybeSingle();
      if (data == null) return null;
      return GoalModel.fromJson(data);
    }
  }

  Future<GoalModel> saveMonthlyGoal(GoalModel goal) async {
    if (_isMock) {
      await _ensureMockInitialized();
      await Future.delayed(const Duration(milliseconds: 400));
      final index = _mockGoals.indexWhere((g) => g.month == goal.month);
      if (index >= 0) {
        _mockGoals[index] = goal;
      } else {
        _mockGoals.add(goal);
      }
      await _saveMockData();
      return goal;
    } else {
      final payload = goal.toJson();
      payload['user_id'] = _client!.auth.currentUser!.id;
      
      final existingCount = await _client!
          .from('goals')
          .select()
          .eq('month', goal.month.toIso8601String())
          .count(CountOption.exact);
          
      if (existingCount.count > 0) {
        // If the goal exists for this month, gracefully update it
        final data = await _client!
            .from('goals')
            .update({'target_amount': goal.targetAmount})
            .eq('month', goal.month.toIso8601String())
            .select()
            .single();        
        return GoalModel.fromJson(data);
      } else {
        final data = await _client!
            .from('goals')
            .insert(payload)
            .select()
            .single();
        return GoalModel.fromJson(data);
      }
    }
  }
}
