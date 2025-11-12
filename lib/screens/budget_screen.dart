import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
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

  // Setup Budget 状态
  bool _showSetupBudget = false;
  List<String> _selectedCategories = [];
  Map<String, double> _categoryAmounts = {};
  int _setupStep = 1;

  // ✅ 修复问题1：将 TextEditingController 保存为状态变量
  Map<String, TextEditingController> _amountControllers = {};

  // 所有可用的 categories
  final List<Map<String, String>> _availableCategories = [
    {'id': 'Food & Dining', 'name': 'Food & Dining', 'emoji': '🍔'},
    {'id': 'Transportation', 'name': 'Transportation', 'emoji': '🚗'},
    {'id': 'Shopping', 'name': 'Shopping', 'emoji': '🛍️'},
    {'id': 'Entertainment', 'name': 'Entertainment', 'emoji': '🎬'},
    {'id': 'Bills & Utilities', 'name': 'Bills & Utilities', 'emoji': '💡'},
    {'id': 'Healthcare', 'name': 'Healthcare', 'emoji': '🏥'},
    {'id': 'Education', 'name': 'Education', 'emoji': '📚'},
    {'id': 'Groceries', 'name': 'Groceries', 'emoji': '🛒'},
    {'id': 'Personal Care', 'name': 'Personal Care', 'emoji': '💅'},
    {'id': 'Other', 'name': 'Other', 'emoji': '📌'},
  ];

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
    // ✅ 修复：清理所有 controllers
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  // 获取还没有 budget 的 categories
  List<Map<String, String>> _getAvailableCategories() {
    final provider = context.read<AppProvider>();
    final existingCategories = provider.budgets
        .where((b) => b.isActive)
        .map((b) => b.category)
        .toSet();

    return _availableCategories.where((cat) {
      return !existingCategories.contains(cat['name']);
    }).toList();
  }

  // 处理下一步
  void _handleNext() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _setupStep = 2;
      // ✅ 修复：为每个选中的 category 创建 controller
      for (var categoryId in _selectedCategories) {
        _categoryAmounts[categoryId] = 0.0;
        _amountControllers[categoryId] = TextEditingController();
      }
    });
  }

  // ✅ 修复问题3：保存时检查并合并相同类别的 budgets
  // ✅ 修复：保存预算方法 - 解决 "Bad state: No element" 错误
  Future<void> _handleSaveBudgets() async {
    // 1. 检查所有金额是否已输入
    for (var categoryId in _selectedCategories) {
      if ((_categoryAmounts[categoryId] ?? 0) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter amount for all categories'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);
      final provider = context.read<AppProvider>();

      // 2. 遍历所有选中的类别
      for (var categoryId in _selectedCategories) {
        final amount = _categoryAmounts[categoryId]!;

        // ✅ 修复：先安全地检查是否存在相同类别的预算
        final hasExistingBudget = provider.budgets.any(
              (b) => b.category == categoryId && b.isActive,
        );

        if (hasExistingBudget) {
          // 如果存在，找到它并更新
          final existingBudget = provider.budgets.firstWhere(
                (b) => b.category == categoryId && b.isActive,
          );

          print('🔄 Updating existing budget for $categoryId');
          await provider.updateBudget(
            budgetId: existingBudget.id,
            amount: amount,
          );
        } else {
          // 如果不存在，创建新的
          print('➕ Creating new budget for $categoryId');
          await provider.createBudget(
            category: categoryId,
            amount: amount,
            startDate: startDate,
            endDate: endDate,
            period: 'monthly',
          );
        }
      }

      // 3. 清理 controllers
      for (var controller in _amountControllers.values) {
        controller.dispose();
      }

      // 4. 重置状态
      setState(() {
        _showSetupBudget = false;
        _selectedCategories.clear();
        _categoryAmounts.clear();
        _amountControllers.clear();
        _setupStep = 1;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budgets created successfully! 💰'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 6. 错误处理
      print('❌ Error saving budgets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ 新增：编辑 budget
  void _editBudget(BuildContext context, dynamic budget) {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
    final successColor = isDarkMode ? SFMSTheme.darkSuccessColor : SFMSTheme.successColor;
    final inputFillColor = isDarkMode ? SFMSTheme.darkBgSecondary : Colors.grey.shade50;

    final TextEditingController controller = TextEditingController(
      text: budget.amount.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Text('✏️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Edit Budget',
                style: TextStyle(color: textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budget.category,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Monthly Budget',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixText: 'RM ',
                  prefixStyle: TextStyle(color: textPrimary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: inputFillColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a valid amount'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  await context.read<AppProvider>().updateBudget(
                    budgetId: budget.id,
                    amount: amount,
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Budget updated successfully! ✅'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ✅ 新增：删除 budget
  void _deleteBudget(BuildContext context, dynamic budget) {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
    final dangerColor = isDarkMode ? SFMSTheme.darkDangerColor : SFMSTheme.dangerColor;
    final dangerBg = isDarkMode ? SFMSTheme.darkDangerColor.withOpacity(0.1) : Colors.red.shade50;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Delete Budget',
                style: TextStyle(color: textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this budget?',
                style: TextStyle(color: textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dangerBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      _getCategoryEmoji(budget.category),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.category,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            _formatCurrency(budget.amount),
                            style: TextStyle(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<AppProvider>().deleteBudget(budget.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Budget deleted successfully! 🗑️'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // 辅助方法：获取 category emoji
  String _getCategoryEmoji(String category) {
    final cat = _availableCategories.firstWhere(
          (c) => c['name'] == category,
      orElse: () => {'emoji': '📌'},
    );
    return cat['emoji']!;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Get budgets for hasBudgets variable
    final appProvider = Provider.of<AppProvider>(context);
    final hasBudgets = appProvider.budgets.where((b) => b.isActive).isNotEmpty;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final cardBg = isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.cardColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextSecondary.withOpacity(0.7) : SFMSTheme.textMuted;
    final dangerColor = isDarkMode ? SFMSTheme.darkDangerColor : SFMSTheme.dangerColor;

    return Stack(
      children: [
        Container(
          color: bgColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final budgets = appProvider.budgets.where((b) => b.isActive).toList();
                final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.amount);
                final totalSpent = appProvider.getMonthlyExpenses();
                final budgetProgress = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

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
                              Text(
                                'Budget Tracker',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
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
                              gradient: isDarkMode
                                  ? LinearGradient(
                                      colors: [
                                        cardBg,
                                        (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor).withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.white,
                                        SFMSTheme.successColor.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isDarkMode ? SFMSTheme.darkCardGlow : SFMSTheme.softCardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly Budget',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: budgetProgress > 90
                                            ? (isDarkMode ? SFMSTheme.accentCoral : Colors.red).withOpacity(0.1)
                                            : (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            budgetProgress > 90 ? '⚠️' : '✓',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${budgetProgress.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: budgetProgress > 90
                                                  ? (isDarkMode ? SFMSTheme.accentCoral : Colors.red)
                                                  : (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      _formatCurrency(totalSpent),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: budgetProgress > 100
                                            ? (isDarkMode ? SFMSTheme.accentCoral : Colors.red)
                                            : textPrimary,
                                      ),
                                    ),
                                    Text(
                                      ' / ${_formatCurrency(totalBudget)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: (budgetProgress / 100).clamp(0.0, 1.0),
                                    backgroundColor: isDarkMode
                                        ? SFMSTheme.darkBgTertiary
                                        : Colors.grey.shade200,
                                    color: budgetProgress > 90
                                        ? (isDarkMode ? SFMSTheme.accentCoral : Colors.red)
                                        : (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor),
                                    minHeight: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(
                                        (totalBudget - totalSpent).clamp(0, double.infinity),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: totalBudget - totalSpent < 0
                                            ? (isDarkMode ? SFMSTheme.accentCoral : Colors.red)
                                            : (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor),
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
                  const SizedBox(height: 32),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${budgets.length} active',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Budget Categories List
                  if (budgets.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const Text(
                            '📊',
                            style: TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No budgets yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first budget to start tracking',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...budgets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final budget = entry.value;
                      final spent = appProvider.getCategoryExpenses(budget.category);
                      final percentage = budget.amount > 0
                          ? (spent / budget.amount * 100).clamp(0, 100)
                          : 0.0;
                      final remaining = (budget.amount - spent).clamp(0, double.infinity);
                      final colors = _getCategoryGradient(context, index);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colors[0].withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              // Show details or navigate
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getCategoryEmoji(budget.category),
                                          style: const TextStyle(fontSize: 24),
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
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Budget: ${_formatCurrency(budget.amount)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ✅ 修复问题4：添加编辑和删除按钮
                                      PopupMenuButton<String>(
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        color: cardColor,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _editBudget(context, budget);
                                          } else if (value == 'delete') {
                                            _deleteBudget(context, budget);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 20, color: textPrimary),
                                                const SizedBox(width: 12),
                                                Text('Edit Budget', style: TextStyle(color: textPrimary)),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, size: 20, color: dangerColor),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Delete Budget',
                                                  style: TextStyle(color: dangerColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Spent',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatCurrency(spent),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Remaining',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_formatCurrency(budget.amount - spent)} left',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      color: Colors.white,
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(0)}% used',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (percentage > 90)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            percentage >= 100 ? 'Over Budget!' : 'Almost there!',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
        ),

        // Create New Budget Button (显示不同文本根据是否有 budget)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - _animationController.value)),
                child: Opacity(
                  opacity: _animationController.value,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSetupBudget = true;
                        _setupStep = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor).withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasBudgets ? Icons.add : Icons.rocket_launch,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          hasBudgets ? 'Create New Budget' : 'Setup Budget',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Setup Budget Dialog
        if (_showSetupBudget)
          GestureDetector(
            onTap: () {
              setState(() {
                _showSetupBudget = false;
                _selectedCategories.clear();
                _categoryAmounts.clear();
                // ✅ 清理 controllers
                for (var controller in _amountControllers.values) {
                  controller.dispose();
                }
                _amountControllers.clear();
                _setupStep = 1;
              });
            },
            child: Container(
              color: Colors.black54,
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // 防止点击对话框内容时关闭
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 600, // 添加最大高度限制
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dialog Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor).withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '💰',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _setupStep == 1
                                          ? 'Select Categories'
                                          : 'Set Amounts',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _setupStep == 1
                                          ? 'Choose categories for your budget'
                                          : 'Enter monthly budget for each category',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showSetupBudget = false;
                                    _selectedCategories.clear();
                                    _categoryAmounts.clear();
                                    // ✅ 清理 controllers
                                    for (var controller in _amountControllers.values) {
                                      controller.dispose();
                                    }
                                    _amountControllers.clear();
                                    _setupStep = 1;
                                  });
                                },
                                icon: Icon(Icons.close, color: textPrimary),
                              ),
                            ],
                          ),
                        ),

                        // Dialog Content
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _setupStep == 1
                                ? _buildCategorySelection(_getAvailableCategories())
                                : _buildAmountInput(),
                          ),
                        ),

                        // Dialog Actions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_setupStep == 2)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _setupStep = 1;
                                        // ✅ 清理 controllers
                                        for (var controller in _amountControllers.values) {
                                          controller.dispose();
                                        }
                                        _amountControllers.clear();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: textPrimary,
                                      side: BorderSide(color: textSecondary),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Back'),
                                  ),
                                ),
                              if (_setupStep == 2) const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _setupStep == 1 ? _handleNext : _handleSaveBudgets,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _setupStep == 1 ? 'Next' : 'Create Budgets',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Category 选择界面
  Widget _buildCategorySelection(List<Map<String, String>> availableCategories) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;

    if (availableCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'All categories have budgets!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have covered all budget categories',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedCategories.length} selected',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor,
          ),
        ),
        const SizedBox(height: 12),
        ...availableCategories.map((category) {
          final isSelected = _selectedCategories.contains(category['id']);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor).withOpacity(0.1)
                  : (isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add(category['id']!);
                  } else {
                    _selectedCategories.remove(category['id']);
                  }
                });
              },
              title: Row(
                children: [
                  Text(
                    category['emoji']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              activeColor: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ✅ 修复问题2：金额输入界面 - 使用状态变量中的 controllers
  Widget _buildAmountInput() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final successColor = isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor;
    final cardBg = isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade50;
    final borderColor = isDarkMode ? SFMSTheme.darkBgSecondary : Colors.grey.shade200;
    final inputBg = isDarkMode ? SFMSTheme.darkBgSecondary : Colors.white;

    return Column(
      children: _selectedCategories.map((categoryId) {
        final category = _availableCategories.firstWhere(
              (cat) => cat['id'] == categoryId,
          orElse: () => {'id': categoryId, 'name': categoryId, 'emoji': '📌'},
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    category['emoji']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                // ✅ 使用状态变量中的 controller
                controller: _amountControllers[categoryId],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter monthly budget',
                  hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                  prefixText: 'RM ',
                  prefixStyle: TextStyle(color: textPrimary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: successColor, width: 2),
                  ),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // ✅ 修复：正确解析并保存金额
                  final amount = double.tryParse(value) ?? 0;
                  setState(() {
                    _categoryAmounts[categoryId] = amount;
                    print('✅ Category: $categoryId, Amount: $amount'); // Debug
                    _categoryAmounts[categoryId] = amount;
                  });
                  print('Category: $categoryId, Amount: $amount'); // Debug
                },
              ),
              // ✅ 添加实时反馈，显示当前输入的金额
              if (_categoryAmounts[categoryId] != null && _categoryAmounts[categoryId]! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Budget: ${_formatCurrency(_categoryAmounts[categoryId]!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? SFMSTheme.accentTeal : SFMSTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Color> _getCategoryGradient(BuildContext context, int index) {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    if (isDarkMode) {
      // Dark mode gradients - darker, more muted colors
      final gradients = [
        [SFMSTheme.darkCartoonPink, const Color(0xFF8B2F5E)],
        [SFMSTheme.darkCartoonPurple, const Color(0xFF5A4B6E)],
        [SFMSTheme.darkCartoonBlue, const Color(0xFF2E5C8C)],
        [SFMSTheme.darkCartoonCyan, const Color(0xFF2E6B7A)],
        [SFMSTheme.darkCartoonMint, const Color(0xFF2E6B5A)],
        [SFMSTheme.darkCartoonYellow, const Color(0xFF8C6E2E)],
        [SFMSTheme.darkCartoonOrange, const Color(0xFF8C4E2E)],
      ];
      return gradients[index % gradients.length];
    } else {
      // Light mode gradients - bright, vibrant colors
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
}
