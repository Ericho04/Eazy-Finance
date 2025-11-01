import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 确保这些路径是正确的
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class AppProvider extends ChangeNotifier {
  // Private fields
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<Goal> _goals = [];
  int _rewardPoints = 850; // Starting points
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<Goal> get goals => _goals;
  int get rewardPoints => _rewardPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  AppProvider() {
    _loadData();
    initializeSampleData();
  }

  // Loading state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Data persistence
  Future<void> _loadData() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();

      // Load transactions
      final transactionsJson = prefs.getString('sfms_transactions');
      if (transactionsJson != null) {
        final List<dynamic> transactionsList = json.decode(transactionsJson);
        _transactions =
            transactionsList.map((json) => Transaction.fromJson(json)).toList();
      }

      // Load budgets
      final budgetsJson = prefs.getString('sfms_budgets');
      if (budgetsJson != null) {
        final List<dynamic> budgetsList = json.decode(budgetsJson);
        _budgets = budgetsList.map((json) => Budget.fromJson(json)).toList();
      }

      // Load goals
      final goalsJson = prefs.getString('sfms_goals');
      if (goalsJson != null) {
        final List<dynamic> goalsList = json.decode(goalsJson);
        _goals = goalsList.map((json) => Goal.fromJson(json)).toList();
      }

      // Load reward points
      _rewardPoints = prefs.getInt('sfms_reward_points') ?? 850;
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save transactions
      final transactionsJson = json.encode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString('sfms_transactions', transactionsJson);

      // Save budgets
      final budgetsJson = json.encode(
        _budgets.map((b) => b.toJson()).toList(),
      );
      await prefs.setString('sfms_budgets', budgetsJson);

      // Save goals
      final goalsJson = json.encode(
        _goals.map((g) => g.toJson()).toList(),
      );
      await prefs.setString('sfms_goals', goalsJson);

      // Save reward points
      await prefs.setInt('sfms_reward_points', _rewardPoints);
    } catch (e) {
      _setError('Failed to save data: $e');
    }
  }

  // Initialize with sample data if empty
  void initializeSampleData() {
    if (_budgets.isEmpty) {
      // Calculate dates for monthly period
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      _budgets = [
        Budget(
          id: '1',
          userId: 'demo-user-123',
          category: 'Food & Dining',
          amount: 500.0,
          spent: 450.0,
          period: BudgetPeriod.monthly, // <-- 来自 budget.dart
          startDate: startDate,
          endDate: endDate,
          createdAt: now,
        ),
        Budget(
          id: '2',
          userId: 'demo-user-123',
          category: 'Transportation',
          amount: 300.0,
          spent: 280.0,
          period: BudgetPeriod.monthly, // <-- 来自 budget.dart
          startDate: startDate,
          endDate: endDate,
          createdAt: now,
        ),
      ];
    }

    if (_goals.isEmpty) {
      _goals = [
        Goal(
          id: '1',
          userId: 'demo-user-123',
          title: 'Emergency Fund',
          description: 'Build 6 months of expenses',
          targetAmount: 15000.0,
          currentAmount: 8500.0,
          deadline: '2024-12-31',
          category: 'emergency',
          priority: 'high',
          isCompleted: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
        Goal(
          id: '2',
          userId: 'demo-user-123',
          title: 'Vacation to Japan',
          description: 'Save for dream vacation',
          targetAmount: 8000.0,
          currentAmount: 3200.0,
          deadline: '2024-10-15',
          category: 'travel',
          priority: 'medium',
          isCompleted: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
        Goal(
          id: '3',
          userId: 'demo-user-123',
          title: 'New Laptop',
          description: 'MacBook Pro for work',
          targetAmount: 2500.0,
          currentAmount: 2500.0,
          deadline: '2024-06-30',
          category: 'technology',
          priority: 'low',
          isCompleted: true,
          completedAt: '2024-06-25',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 90))
              .toIso8601String(),
        ),
      ];
    }

    // Save initial data
    _saveData();
    notifyListeners();
  }

  // Transaction methods
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final newTransaction = transaction.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _transactions.add(newTransaction);

      // Update budget spending if applicable
      _updateBudgetSpending(newTransaction);

      await _saveData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        await _saveData();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      _transactions.removeWhere((t) => t.id == id);
      await _saveData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete transaction: $e');
    }
  }

  // Budget methods
  Future<void> addBudget(Budget budget) async {
    try {
      final newBudget = budget.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _budgets.add(newBudget);
      await _saveData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add budget: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        await _saveData();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update budget: $e');
    }
  }

  void _updateBudgetSpending(Transaction transaction) {
    if (transaction.type == TransactionType.expense) { // <-- 来自 transaction.dart
      final budgetIndex = _budgets.indexWhere(
            (b) => b.category.toLowerCase() == transaction.category.toLowerCase(),
      );

      if (budgetIndex != -1) {
        _budgets[budgetIndex] = _budgets[budgetIndex].copyWith(
          spent: _budgets[budgetIndex].spent + transaction.amount,
        );
      }
    }
  }

  // Goal methods
  Future<void> addGoal(Goal goal) async {
    try {
      final newGoal = goal.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _goals.add(newGoal);
      await _saveData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add goal: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        await _saveData();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update goal: $e');
    }
  }

  Future<void> contributeToGoal(String goalId, double amount) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        final goal = _goals[index];
        final newAmount = goal.currentAmount + amount;
        final isCompleted = newAmount >= goal.targetAmount;

        _goals[index] = goal.copyWith(
          currentAmount: isCompleted ? goal.targetAmount : newAmount,
          isCompleted: isCompleted,
          completedAt:
          isCompleted ? DateTime.now().toIso8601String() : goal.completedAt,
        );

        // Award points for completing goal
        if (isCompleted && !goal.isCompleted) {
          final pointsReward = (goal.targetAmount / 100).floor();
          _rewardPoints += pointsReward;
        }

        await _saveData();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to contribute to goal: $e');
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      _goals.removeWhere((g) => g.id == id);
      await _saveData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete goal: $e');
    }
  }

  // Reward points methods
  Future<void> addRewardPoints(int points) async {
    try {
      _rewardPoints += points;
      await _saveData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add reward points: $e');
    }
  }

  Future<void> spendRewardPoints(int points) async {
    try {
      if (_rewardPoints >= points) {
        _rewardPoints -= points;
        await _saveData();
        notifyListeners();
      } else {
        _setError('Insufficient reward points');
      }
    } catch (e) {
      _setError('Failed to spend reward points: $e');
    }
  }

  // Analytics methods
  double getMonthlyExpenses() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return _transactions
        .where((t) =>
    t.type == TransactionType.expense &&
        DateTime.parse(t.date).isAfter(currentMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getCategorySpending(String category) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return _transactions
        .where((t) =>
    t.type == TransactionType.expense &&
        t.category.toLowerCase() == category.toLowerCase() &&
        DateTime.parse(t.date).isAfter(currentMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategoryBreakdown() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final expenses = _transactions
        .where((t) =>
    t.type == TransactionType.expense &&
        DateTime.parse(t.date).isAfter(currentMonth))
        .toList();

    final Map<String, double> breakdown = {};

    for (final expense in expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
    }

    return breakdown;
  }

  List<Transaction> getRecentTransactions({int limit = 10}) {
    final sortedTransactions = List<Transaction>.from(_transactions);
    sortedTransactions.sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return sortedTransactions.take(limit).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      final transactionDate = DateTime.parse(t.date);
      return transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> getTodayTransactions() {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _transactions.where((t) => t.date == todayString).toList();
  }

  // Clear all data (for demo/testing)
  Future<void> clearAllData() async {
    try {
      _transactions.clear();
      _budgets.clear();
      _goals.clear();
      _rewardPoints = 850;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sfms_transactions');
      await prefs.remove('sfms_budgets');
      await prefs.remove('sfms_goals');
      await prefs.remove('sfms_reward_points');

      initializeSampleData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear data: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}