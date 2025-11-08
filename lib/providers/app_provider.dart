// [*** providers/app_provider.dart - 完整替换版 (连接 Supabase) ***]

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert'; // 保留，以防你的模型需要

// 确保这些路径是正确的
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class AppProvider extends ChangeNotifier {
  // 1. 添加 Supabase 客户端
  final supabase = Supabase.instance.client;

  // 2. 移除模拟数据，用空列表初始化
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<Goal> _goals = [];
  int _rewardPoints = 0; // 将从数据库加载
  bool _isLoading = false;
  String? _error;

  // Getters (你原有的 Getters 保持不变)
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<Goal> get goals => _goals;
  int get rewardPoints => _rewardPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 3. 移除构造函数中的 _loadData() 和 initializeSampleData()
  AppProvider() {
    // 构造函数现在是空的，等待 main.dart 通知登录
  }

  // Loading state management (保持不变)
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  //
  // 4. [*** 核心功能：从 Supabase 加载数据 ***]
  //
  Future<void> fetchAllData() async {
    // 检查用户是否已登录
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('fetchAllData: User is null, clearing data.');
      _clearLocalData(); // 如果用户为空，则清除本地数据
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      // 并行运行所有数据获取
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

  // 5. 创建 fetchTransactions
  Future<void> fetchTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id) // 🔑 只获取这个用户的！
          .order('date', ascending: false); // 按日期排序

      //
      // ⚠️ 关键假设:
      // 这假设你的 'transaction.dart' 模型文件有一个
      // factory Transaction.fromJson(Map<String, dynamic> json) 构造函数
      //
      _transactions = response
          .map((item) => Transaction.fromJson(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e');
      _setError('Could not load transactions.');
    }
  }

  // 6. 创建 fetchBudgets
  Future<void> fetchBudgets() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('budgets')
          .select()
          .eq('user_id', user.id) // 🔑 只获取这个用户的！
          .eq('is_active', true); // 🔑 只获取当前活跃的预算

      // ⚠️ 关键假设: 你的 'budget.dart' 有 .fromJson
      _budgets = response
          .map((item) => Budget.fromJson(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching budgets: $e');
      _setError('Could not load budgets.');
    }
  }

  // 7. 创建 fetchGoals
  Future<void> fetchGoals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('goals')
          .select()
          .eq('user_id', user.id) // 🔑 只获取这个用户的！
          .order('deadline', ascending: true);

      // ⚠️ 关键假设: 你的 'goal.dart' 有 .fromJson
      _goals = response
          .map((item) => Goal.fromJson(item))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching goals: $e');
      _setError('Could not load goals.');
    }
  }

  // 8. (可选) 获取积分
  Future<void> fetchRewardPoints() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 假设你的积分存储在 'user_profiles' 表
      final response = await supabase
          .from('user_profiles')
          .select('reward_points')
          .eq('id', user.id)
          .single(); // 获取单条记录

      _rewardPoints = response['reward_points'] ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error fetching reward points: $e');
      // 不把它设为严重错误
    }
  }

  // 9. 登出时清除数据
  void _clearLocalData() {
    _transactions = [];
    _budgets = [];
    _goals = [];
    _rewardPoints = 0;
    _error = null;
    notifyListeners();
  }

  //
  // --- 移除所有 SharedPreferences 和 SampleData 函数 ---
  //
  // 移除了 initializeSampleData()
  // 移除了 _loadData()
  // 移除了 _saveData()
  // 移除了 clearAllData()
  // 移除了 _addTransaction, _addBudget, fundGoal (这些现在在屏幕或 Supabase Function 中处理)
  //

  //
  // --- 计算属性 (Getters) ---
  // (你原有的 helper/getter 函数保持不变，因为它们很有用)
  //

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
    // 你的 Budget 模型需要有 'spent' 属性
    // 假设它已经有了
    return _budgets.fold(0.0, (sum, b) => sum + b.spent);
  }

  List<Transaction> getRecentTransactions({int limit = 5}) {
    // _transactions 已经从 Supabase 按日期排序
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