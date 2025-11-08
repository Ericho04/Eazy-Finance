// [*** 修复后的 dashboard_screen.dart ***]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✨ 第 1 步：修复 Imports
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
// (我们删除了 'import ../main.dart;')


class DashboardScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const DashboardScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _cardController;
  late AnimationController _bounceController;
  late Animation<double> _greetingAnimation;
  late Animation<Offset> _cardAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _greetingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));

    // Start animations
    _greetingController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
    _bounceController.repeat(reverse: true);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning! ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon! 🌤️';
    } else {
      return 'Good Evening! 🌙';
    }
  }

  String _getUserName() {
    final user = context.read<AuthProvider>().user;
    final metadata = user?.userMetadata;
    return metadata?['full_name'] ?? 'User';
  }

  // ✨ 第 2 步：修复 Transaction 逻辑 (类型和日期)
  double _getTotalBalance() {
    final transactions = context.read<AppProvider>().transactions;
    double balance = 0;
    for (var transaction in transactions) {
      // 修复: 'income' -> TransactionType.income
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  double _getMonthlyIncome() {
    final transactions = context.read<AppProvider>().transactions;
    final now = DateTime.now();
    final thisMonth = transactions.where((t) {
      final tDate = DateTime.parse(t.date); // 修复: t.date 是 String
      return t.type == TransactionType.income && // 修复: 'income' -> TransactionType.income
          tDate.year == now.year &&
          tDate.month == now.month;
    });
    return thisMonth.fold(0.0, (sum, t) => sum + t.amount);
  }

  double _getMonthlyExpenses() {
    final transactions = context.read<AppProvider>().transactions;
    final now = DateTime.now();
    final thisMonth = transactions.where((t) {
      final tDate = DateTime.parse(t.date); // 修复: t.date 是 String
      return t.type == TransactionType.expense && // 修复: 'expense' -> TransactionType.expense
          tDate.year == now.year &&
          tDate.month == now.month;
    });
    return thisMonth.fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    //
    // 💡 [*** 在这里修复 ***] 💡
    // 我们移除了 Scaffold 和 body:
    //
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Greeting Section
          FadeTransition(
            opacity: _greetingAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getUserName(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Balance Card
          SlideTransition(
            position: _cardAnimation,
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E8EF7), Color(0xFF845EC2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4E8EF7).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'My Wallet 💰',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RM ${_getTotalBalance().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildBalanceItem(
                          '📈',
                          'Income',
                          _getMonthlyIncome(),
                          Colors.green.shade400,
                        ),
                        const SizedBox(width: 24),
                        _buildBalanceItem(
                          '📉',
                          'Expenses',
                          _getMonthlyExpenses(),
                          Colors.red.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '➕',
                  'Add Expense',
                  'Track your spending',
                  const Color(0xFF845EC2),
                      () => widget.onNavigate('add-expense'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  '📊',
                  'View Reports',
                  'Analyze your data',
                  const Color(0xFF4E8EF7),
                      () => widget.onNavigate('reports'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '📱',
                  'Scan QR',
                  'Quick payment',
                  const Color(0xFF4FFBDF),
                      () => widget.onNavigate('qr-scan'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  '🎰',
                  'Lucky Draw',
                  'Win rewards',
                  const Color(0xFFFFD93D),
                      () => widget.onNavigate('lucky-draw'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate('expense-history'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF4E8EF7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction List
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              // ✨ 修复: 使用 getRecentTransactions()
              final recentTransactions = appProvider.getRecentTransactions(limit: 5);

              if (recentTransactions.isEmpty) {
                return _buildEmptyTransactions();
              }

              return Column(
                children: recentTransactions
                    .map((transaction) => _buildTransactionItem(transaction))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 32),

          // Budget Overview
          const Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (appProvider.budgets.isEmpty) {
                return _buildEmptyBudgets();
              }

              return Column(
                children: appProvider.budgets
                    .take(3)
                    .map((budget) => _buildBudgetItem(budget))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 100), // Extra space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String emoji, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'RM ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String emoji,
      String title,
      String subtitle,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ 第 3 步：修复 Transaction 和 Budget 的 UI
  Widget _buildTransactionItem(Transaction transaction) {
    // 修复: 'income' -> TransactionType.income
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description, // 属性存在
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.category, // 属性存在
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}RM ${transaction.amount.toStringAsFixed(2)}', // 属性存在
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(DateTime.parse(transaction.date)), // 修复: date 是 String
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
    // 修复: 适配新的 Budget 模型
    final percentage = budget.utilizationPercentage / 100; // .utilizationPercentage 是 0-100
    final color = percentage > 0.8 ? Colors.red : Colors.blue; // 修复: 新模型没有 .color

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '💰', // 修复: 新模型没有 .icon
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category, // 修复: 新模型没有 .name，使用 .category
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // 属性存在
                      'RM ${budget.spent.toStringAsFixed(2)} / RM ${budget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                // 修复: 使用 .utilizationPercentage
                '${budget.utilizationPercentage.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage, // 修复: 使用 0-1.0 的百分比
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt_long,
              size: 32,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your expenses',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBudgets() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.pie_chart,
              size: 32,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No budgets set',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create budgets to manage spending',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _cardController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
}