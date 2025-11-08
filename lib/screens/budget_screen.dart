import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class BudgetScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const BudgetScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.forward();
    _pulseController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final budgets = appProvider.budgets;
          final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.amount);
          final totalSpent = appProvider.getMonthlyExpenses();
          final budgetProgress = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + math.sin(_pulseController.value * 2 * math.pi) * 0.1,
                                child: const Text(
                                  '💳',
                                  style: TextStyle(fontSize: 40),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Budget Tracker',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Monthly Overview Card
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              SFMSTheme.successColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Monthly Budget',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(totalBudget),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Spent',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(totalSpent),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: totalSpent > totalBudget
                                            ? SFMSTheme.dangerColor
                                            : SFMSTheme.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Budget Usage: ${budgetProgress.toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    Text(
                                      'Remaining: ${_formatCurrency(math.max(totalBudget - totalSpent, 0))}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: math.min(budgetProgress / 100, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: budgetProgress > 100
                                              ? [Colors.red.shade400, Colors.red.shade600]
                                              : budgetProgress > 80
                                                  ? [Colors.orange.shade400, Colors.orange.shade600]
                                                  : [SFMSTheme.successColor, Colors.green.shade600],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Category Budgets
              const Text(
                'Budget Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),

              if (budgets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        'No budgets set yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by creating your first budget category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add budget functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Budget creation coming soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Budget'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SFMSTheme.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: budgets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final budget = entry.value;
                    final categorySpent = appProvider.getCategorySpending(budget.category);
                    final categoryProgress = budget.amount > 0 ? (categorySpent / budget.amount) * 100 : 0;

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, (70 + index * 20) * (1 - _animationController.value)),
                          child: Opacity(
                            opacity: _animationController.value,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _getCategoryGradient(index),
                                          ),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Center(
                                          child: Text(
                                            budget.category.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              budget.category,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            Text(
                                              'Budget: ${_formatCurrency(budget.amount)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatCurrency(categorySpent),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: categorySpent > budget.amount
                                                  ? SFMSTheme.dangerColor
                                                  : SFMSTheme.successColor,
                                            ),
                                          ),
                                          Text(
                                            '${categoryProgress.toInt()}%',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: categorySpent > budget.amount
                                                  ? SFMSTheme.dangerColor
                                                  : SFMSTheme.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Category Progress Bar
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: math.min(categoryProgress / 100, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: categoryProgress > 100
                                                ? [Colors.red.shade400, Colors.red.shade600]
                                                : categoryProgress > 80
                                                    ? [Colors.orange.shade400, Colors.orange.shade600]
                                                    : _getCategoryGradient(index),
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Remaining: ${_formatCurrency(math.max(budget.amount - categorySpent, 0))}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      if (categorySpent > budget.amount)
                                        Text(
                                          'Over by: ${_formatCurrency(categorySpent - budget.amount)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: SFMSTheme.dangerColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // Add Budget Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: SFMSTheme.cartoonBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget management coming soon!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Create New Budget 🎯',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Extra padding for bottom navigation
            ],
          );
        },
      ),
    );
  }

  List<Color> _getCategoryGradient(int index) {
    final gradients = [
      [SFMSTheme.cartoonPink, const Color(0xFFFF8CC8)],
      [SFMSTheme.cartoonPurple, const Color(0xFFB39BC8)],
      [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
      [SFMSTheme.cartoonCyan, const Color(0xFF66E7FF)],
      [SFMSTheme.cartoonMint, const Color(0xFFA0FFE6)],
      [SFMSTheme.cartoonYellow, const Color(0xFFFFE066)],
      [SFMSTheme.cartoonOrange, const Color(0xFFFFAB66)],
    ];
    return gradients[index % gradients.length];
  }
}

