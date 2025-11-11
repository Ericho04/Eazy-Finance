// [*** providers/app_provider.dart - 完全修复版 ***]
// ✅ 已修复所有 Dart Analysis 错误
// ✅ 添加了所有缺失的方法：updateBudget, deleteBudget, getCategoryExpenses

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

// 确保这些路径是正确的
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class AppProvider extends ChangeNotifier {
  // 1. Supabase 客户端
  final supabase = Supabase.instance.client;

  // 2. 数据状态
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<Goal> _goals = [];
  int _rewardPoints = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<Goal> get goals => _goals;
  int get rewardPoints => _rewardPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 构造函数
  AppProvider();

  // Loading state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // ==========================================================================
  // 核心数据加载方法
  // ==========================================================================

  Future<void> fetchAllData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('fetchAllData: User is null, clearing data.');
      clearLocalData();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      await Future.wait([
        fetchTransactions(),
        fetchBudgets(),
        fetchGoals(),
        fetchRewardPoints(),
      ]);
    } catch (e) {
      _setError('Failed to fetch data: $e');
      print('Error fetching all data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('transaction_date', ascending: false);

      _transactions = response
          .map((item) => Transaction.fromJson(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e');
      _setError('Could not load transactions.');
    }
  }

  Future<void> fetchBudgets() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('budgets')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true);

      _budgets = response
          .map((item) => Budget.fromJson(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching budgets: $e');
      _setError('Could not load budgets.');
    }
  }

  Future<void> fetchGoals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('goals')
          .select()
          .eq('user_id', user.id)
          .order('deadline', ascending: true);

      _goals = response
          .map((item) => Goal.fromJson(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching goals: $e');
      _setError('Could not load goals.');
    }
  }

  Future<void> fetchRewardPoints() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('user_profiles')
          .select('reward_points')
          .eq('id', user.id)
          .single();

      _rewardPoints = response['reward_points'] ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error fetching reward points: $e');
    }
  }

  // ✅ 修复 1: 改为 public 方法（main.dart:255 需要）
  void clearLocalData() {
    _transactions = [];
    _budgets = [];
    _goals = [];
    _rewardPoints = 0;
    _error = null;
    notifyListeners();
  }

  // ==========================================================================
  // 基本计算属性
  // ==========================================================================

  double get totalBalance {
    return _transactions.fold(0.0, (sum, t) {
      return sum + (t.type == TransactionType.income ? t.amount : -t.amount);
    });
  }

  double get totalMonthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) {
      final tDate = DateTime.parse(t.date);
      return t.type == TransactionType.income &&
          tDate.year == now.year &&
          tDate.month == now.month;
    })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalMonthlyExpenses {
    final now = DateTime.now();
    return _transactions
        .where((t) {
      final tDate = DateTime.parse(t.date);
      return t.type == TransactionType.expense &&
          tDate.year == now.year &&
          tDate.month == now.month;
    })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBudgetAmount {
    return _budgets.fold(0.0, (sum, b) => sum + b.amount);
  }

  double get totalBudgetSpent {
    return _budgets.fold(0.0, (sum, b) => sum + b.spent);
  }

  // ==========================================================================
  // ✅ 修复：添加所有缺失的方法
  // ==========================================================================

  // ✅ 修复 2: getMonthlyExpenses 方法
  // 被调用位置: budget_screen:55, insights_screen:71, insights_screen:163
  double getMonthlyExpenses() {
    final now = DateTime.now();
    return _transactions
        .where((t) {
      final tDate = DateTime.parse(t.date);
      return t.type == TransactionType.expense &&
          tDate.year == now.year &&
          tDate.month == now.month;
    })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ✅ 修复 3: getCategorySpending 方法
  // 被调用位置: budget_screen:317
  double getCategorySpending(String category, {DateTime? month}) {
    final targetMonth = month ?? DateTime.now();

    return _transactions
        .where((t) {
      final tDate = DateTime.parse(t.date);
      return t.type == TransactionType.expense &&
          t.category == category &&
          tDate.year == targetMonth.year &&
          tDate.month == targetMonth.month;
    })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ✅ 修复 13: getCategoryExpenses 方法（budget_screen:654 需要）
  // 这是 getCategorySpending 的别名
  double getCategoryExpenses(String category) {
    return getCategorySpending(category);
  }

  // ✅ 修复 4: getCategoryBreakdown 方法
  // 被调用位置: insights_screen:72
  Map<String, double> getCategoryBreakdown({DateTime? month}) {
    final targetMonth = month ?? DateTime.now();
    final Map<String, double> breakdown = {};

    for (var transaction in _transactions) {
      final tDate = DateTime.parse(transaction.date);

      if (transaction.type == TransactionType.expense &&
          tDate.year == targetMonth.year &&
          tDate.month == targetMonth.month) {

        breakdown[transaction.category] =
            (breakdown[transaction.category] ?? 0.0) + transaction.amount;
      }
    }

    return breakdown;
  }

  // ✅ 修复 5 & 6: 支出和收入分类 getters
  // 被调用位置: expense_entry_screen:139, expense_entry_screen:140
  List<Map<String, dynamic>> get expenseCategories {
    return [
      {'id': 'food', 'name': 'Food & Dining', 'emoji': '🍔'},
      {'id': 'transport', 'name': 'Transportation', 'emoji': '🚗'},
      {'id': 'shopping', 'name': 'Shopping', 'emoji': '🛍️'},
      {'id': 'entertainment', 'name': 'Entertainment', 'emoji': '🎬'},
      {'id': 'bills', 'name': 'Bills & Utilities', 'emoji': '💡'},
      {'id': 'healthcare', 'name': 'Healthcare', 'emoji': '⚕️'},
      {'id': 'education', 'name': 'Education', 'emoji': '📚'},
      {'id': 'other', 'name': 'Other', 'emoji': '📦'},
    ];
  }

  List<Map<String, dynamic>> get incomeCategories {
    return [
      {'id': 'salary', 'name': 'Salary', 'emoji': '💼'},
      {'id': 'business', 'name': 'Business', 'emoji': '🏢'},
      {'id': 'investment', 'name': 'Investment', 'emoji': '📈'},
      {'id': 'freelance', 'name': 'Freelance', 'emoji': '💻'},
      {'id': 'gift', 'name': 'Gift', 'emoji': '🎁'},
      {'id': 'other', 'name': 'Other', 'emoji': '💰'},
    ];
  }

  // ==========================================================================
  // Budget 管理方法
  // ==========================================================================

  // 创建新预算
  Future<void> createBudget({
    required String category,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    String period = 'monthly',
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await supabase.from('budgets').insert({
        'user_id': user.id,
        'category': category,
        'amount': amount,
        'spent': 0.0,
        'period': period,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': true,
      });

      await fetchBudgets();
      print('✅ Budget created: $category - RM $amount');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to create budget: $e');
    }
  }

  // ✅ 修复 11: updateBudget 方法
  // 被调用位置: budget_screen:141, budget_screen:253
  Future<void> updateBudget({
    required String budgetId,
    double? amount,
    double? spent,
    bool? isActive,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final Map<String, dynamic> updates = {};

      if (amount != null) updates['amount'] = amount;
      if (spent != null) updates['spent'] = spent;
      if (isActive != null) updates['is_active'] = isActive;

      if (updates.isEmpty) {
        print('⚠️ No updates provided for budget');
        return;
      }

      await supabase
          .from('budgets')
          .update(updates)
          .eq('id', budgetId)
          .eq('user_id', user.id);

      await fetchBudgets();
      print('✅ Budget updated: $budgetId');
    } catch (e) {
      print('❌ Error updating budget: $e');
      throw Exception('Failed to update budget: $e');
    }
  }

  // ✅ 修复 12: deleteBudget 方法
  // 被调用位置: budget_screen:355
  Future<void> deleteBudget(String budgetId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // 软删除：设置 is_active 为 false
      await supabase
          .from('budgets')
          .update({'is_active': false})
          .eq('id', budgetId)
          .eq('user_id', user.id);

      // 或者硬删除（如果需要）：
      // await supabase
      //     .from('budgets')
      //     .delete()
      //     .eq('id', budgetId)
      //     .eq('user_id', user.id);

      await fetchBudgets();
      print('✅ Budget deleted: $budgetId');
    } catch (e) {
      print('❌ Error deleting budget: $e');
      throw Exception('Failed to delete budget: $e');
    }
  }

  // ==========================================================================
  // Goal 管理方法
  // ==========================================================================

  Future<void> addGoal(Goal goal) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await supabase.from('goals').insert({
        'user_id': user.id,
        'title': goal.title,
        'description': goal.description,
        'target_amount': goal.targetAmount,
        'current_amount': goal.currentAmount,
        'category': goal.category,
        'deadline': goal.deadline,
        'priority': goal.priority,
        'is_completed': goal.isCompleted,
        'points_reward': goal.pointsReward,
      });

      await fetchGoals();
    } catch (e) {
      print('Error adding goal: $e');
      throw Exception('Failed to add goal');
    }
  }

  // ✅ 修复 8: contributeToGoal 方法
  // 被调用位置: goals_screen:125
  Future<void> contributeToGoal(String goalId, double amount) async {
    try {
      // 找到目标
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final newAmount = goal.currentAmount + amount;
      final isCompleted = newAmount >= goal.targetAmount;

      // 更新 Supabase
      await supabase.from('goals').update({
        'current_amount': newAmount,
        'is_completed': isCompleted,
      }).eq('id', goalId);

      // 重新加载目标
      await fetchGoals();
    } catch (e) {
      print('Error contributing to goal: $e');
      throw Exception('Failed to contribute to goal');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await supabase.from('goals').delete().eq('id', goalId);
      await fetchGoals();
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  // ==========================================================================
  // Reward Points 管理
  // ==========================================================================

  // ✅ 修复 9: spendRewardPoints 方法
  // 被调用位置: lucky_draw_screen:87, rewards_shop_screen:62
  Future<void> spendRewardPoints(int points) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    if (_rewardPoints < points) {
      throw Exception('Insufficient reward points');
    }

    try {
      final newPoints = _rewardPoints - points;

      await supabase.from('user_profiles').update({
        'reward_points': newPoints,
      }).eq('id', user.id);

      _rewardPoints = newPoints;
      notifyListeners();
    } catch (e) {
      print('Error spending reward points: $e');
      throw Exception('Failed to spend reward points');
    }
  }

  // ✅ 修复 10: addRewardPoints 方法
  // 被调用位置: lucky_draw_screen:121
  Future<void> addRewardPoints(int points) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final newPoints = _rewardPoints + points;

      await supabase.from('user_profiles').update({
        'reward_points': newPoints,
      }).eq('id', user.id);

      _rewardPoints = newPoints;
      notifyListeners();
    } catch (e) {
      print('Error adding reward points: $e');
      throw Exception('Failed to add reward points');
    }
  }

  // ==========================================================================
  // 其他辅助方法
  // ==========================================================================

  List<Transaction> getRecentTransactions({int limit = 5}) {
    return _transactions.take(limit).toList();
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
    final todayDate = DateTime(today.year, today.month, today.day);

    return _transactions.where((t) {
      final transactionDate = DateTime.parse(t.date);
      final tDate = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
      return tDate.isAtSameMomentAs(todayDate);
    }).toList();
  }
}