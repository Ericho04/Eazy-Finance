import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../utils/theme.dart';
import '../widget/modern_ui_components.dart';

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

  double _getDailyExpenses() {
    final transactions = context.read<AppProvider>().transactions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayExpenses = transactions.where((t) {
      final tDate = DateTime.parse(t.date);
      final transactionDay = DateTime(tDate.year, tDate.month, tDate.day);
      return t.type == TransactionType.expense && transactionDay == today;
    });

    return todayExpenses.fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SFMSTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SFMSTheme.spacing20),

          // Greeting Section - Using theme colors
          FadeTransition(
            opacity: _greetingAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SFMSTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: SFMSTheme.spacing4),
                Text(
                  _getUserName(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: SFMSTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: SFMSTheme.spacing32),

          // Balance Card - Using BalanceCard component with theme gradient
          SlideTransition(
            position: _cardAnimation,
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(SFMSTheme.spacing24),
                decoration: BoxDecoration(
                  gradient: SFMSTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
                  boxShadow: SFMSTheme.accentShadow(SFMSTheme.primaryColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Expenses',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                            SizedBox(height: SFMSTheme.spacing8),
                            Row(
                              children: [
                                Text(
                                  'My Wallet ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Text(
                                  '💰',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(SFMSTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(SFMSTheme.radiusMedium),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: SFMSTheme.iconSizeLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SFMSTheme.spacing16),
                    Text(
                      'RM ${_getDailyExpenses().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: SFMSTheme.spacing8),
                    Text(
                      'Daily spending tracker',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: SFMSTheme.spacing32),

          // Quick Actions - Using theme colors
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: SFMSTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: SFMSTheme.spacing16),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '➕',
                  'Add Expense',
                  'Track your spending',
                  SFMSTheme.cartoonPurple,
                  () => widget.onNavigate('add-expense'),
                ),
              ),
              SizedBox(width: SFMSTheme.spacing16),
              Expanded(
                child: _buildQuickActionCard(
                  '🎯',
                  'Add Goal',
                  'Set your targets',
                  SFMSTheme.primaryLight,
                  () => widget.onNavigate('goals'),
                ),
              ),
            ],
          ),

          SizedBox(height: SFMSTheme.spacing16),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  '📋',
                  'Tax Planning',
                  'Plan your taxes',
                  SFMSTheme.cartoonCyan,
                  () => widget.onNavigate('tax-planning'),
                ),
              ),
              SizedBox(width: SFMSTheme.spacing16),
              Expanded(
                child: _buildQuickActionCard(
                  '🎰',
                  'Lucky Draw',
                  'Win rewards',
                  SFMSTheme.cartoonYellow,
                  () => widget.onNavigate('lucky-draw'),
                ),
              ),
            ],
          ),

          SizedBox(height: SFMSTheme.spacing32),

          // Recent Transactions - Using theme colors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: SFMSTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate('expense-history'),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: SFMSTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SFMSTheme.spacing16),

          // Transaction List
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final recentTransactions =
                  appProvider.getRecentTransactions(limit: 5);

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

          SizedBox(height: SFMSTheme.spacing32),

          // Budget Overview - Using theme colors
          Text(
            'Budget Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: SFMSTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: SFMSTheme.spacing16),

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
        padding: EdgeInsets.all(SFMSTheme.spacing20),
        decoration: BoxDecoration(
          color: SFMSTheme.cardColor,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
          boxShadow: SFMSTheme.softCardShadow,
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: SFMSTheme.spacing12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SFMSTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: SFMSTheme.spacing4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SFMSTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? SFMSTheme.successColor : SFMSTheme.dangerColor;

    return Container(
      margin: EdgeInsets.only(bottom: SFMSTheme.spacing12),
      padding: EdgeInsets.all(SFMSTheme.spacing16),
      decoration: BoxDecoration(
        color: SFMSTheme.cardColor,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
        boxShadow: SFMSTheme.softCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(SFMSTheme.radiusSmall),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: SFMSTheme.iconSizeMedium,
            ),
          ),
          SizedBox(width: SFMSTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SFMSTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: SFMSTheme.spacing4),
                Text(
                  transaction.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SFMSTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}RM ${transaction.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: SFMSTheme.spacing4),
              Text(
                _formatDate(DateTime.parse(transaction.date)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SFMSTheme.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
    final percentage = budget.utilizationPercentage / 100;
    final color = percentage > 0.8
        ? SFMSTheme.dangerColor
        : percentage > 0.6
            ? SFMSTheme.warningColor
            : SFMSTheme.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: SFMSTheme.spacing12),
      padding: EdgeInsets.all(SFMSTheme.spacing16),
      decoration: BoxDecoration(
        color: SFMSTheme.cardColor,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
        boxShadow: SFMSTheme.softCardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(SFMSTheme.radiusSmall),
                ),
                child: const Center(
                  child: Text(
                    '💰',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(width: SFMSTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: SFMSTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: SFMSTheme.spacing4),
                    Text(
                      'RM ${budget.spent.toStringAsFixed(2)} / RM ${budget.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SFMSTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${budget.utilizationPercentage.toInt()}%',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: SFMSTheme.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(SFMSTheme.radiusSmall / 2),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: EdgeInsets.all(SFMSTheme.spacing32),
      decoration: BoxDecoration(
        color: SFMSTheme.neutralLight,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SFMSTheme.neutralMedium.withOpacity(0.3),
                  SFMSTheme.neutralMedium.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
            ),
            child: Icon(
              Icons.receipt_long,
              size: SFMSTheme.iconSizeXLarge,
              color: SFMSTheme.neutralDark,
            ),
          ),
          SizedBox(height: SFMSTheme.spacing16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SFMSTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: SFMSTheme.spacing8),
          Text(
            'Start tracking your expenses',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SFMSTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBudgets() {
    return Container(
      padding: EdgeInsets.all(SFMSTheme.spacing32),
      decoration: BoxDecoration(
        color: SFMSTheme.neutralLight,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SFMSTheme.neutralMedium.withOpacity(0.3),
                  SFMSTheme.neutralMedium.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
            ),
            child: Icon(
              Icons.pie_chart,
              size: SFMSTheme.iconSizeXLarge,
              color: SFMSTheme.neutralDark,
            ),
          ),
          SizedBox(height: SFMSTheme.spacing16),
          Text(
            'No budgets set',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SFMSTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: SFMSTheme.spacing8),
          Text(
            'Create budgets to manage spending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SFMSTheme.textMuted,
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
