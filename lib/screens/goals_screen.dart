import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sfms_flutter/providers/auth_provider.dart';
import 'dart:math' as math;

import '../providers/app_provider.dart';
import '../models/goal.dart';
import '../utils/theme.dart';

class GoalsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const GoalsScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  bool _showAddGoal = false;
  bool _showContributeDialog = false;
  String _selectedGoalId = '';
  final _contributeController = TextEditingController();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _deadlineController = TextEditingController();
  String _selectedCategory = 'savings';
  String _selectedPriority = 'medium';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animationController.forward();
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _deadlineController.dispose();
    _contributeController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

// ✅ 新增方法 1：处理贡献金额
  Future<void> _handleContribute() async {
    if (_contributeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final amount = double.parse(_contributeController.text);
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Amount must be greater than 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _handleContributeToGoal(_selectedGoalId, amount);

      _contributeController.clear();
      setState(() {
        _showContributeDialog = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contributed RM${amount.toStringAsFixed(2)}! 💰'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid amount: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// ✅ 新增方法 2：自定义金额对话框
  Widget _buildContributeDialog() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Money',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showContributeDialog = false;
                        _contributeController.clear();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _contributeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: 'RM ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContribute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SFMSTheme.cartoonPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Money',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getProgressPercentage(double current, double target) {
    return math.min((current / target) * 100, 100);
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'savings': '💰',
      'emergency': '🆘',
      'travel': '✈️',
      'technology': '💻',
      'education': '📚',
      'health': '🏥',
      'home': '🏠',
      'car': '🚗',
      'investment': '📈',
    };
    return emojis[category] ?? '🎯';
  }

  void _handleAddGoal() {
    if (_titleController.text.isNotEmpty &&
        _targetAmountController.text.isNotEmpty) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      final goal = Goal(
        id: '',
        userId: context.read<AuthProvider>().user?.id??'',
        title: _titleController.text,
        description: _descriptionController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: 0,
        deadline: _deadlineController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        isCompleted: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      appProvider.addGoal(goal);

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _targetAmountController.clear();
      _deadlineController.clear();
      _selectedCategory = 'savings';
      _selectedPriority = 'medium';

      setState(() {
        _showAddGoal = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created successfully! 🎯'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleContributeToGoal(String goalId, double amount) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.contributeToGoal(goalId, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final goals = appProvider.goals;
              final activeGoals = goals.where((goal) => !goal.isCompleted).toList();
              final completedGoals = goals.where((goal) => goal.isCompleted).toList();
              final totalGoalsValue = goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
              final totalSaved = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
              final userPoints = appProvider.rewardPoints;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Header with Points
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -50 * (1 - _animationController.value)),
                        child: Opacity(
                          opacity: _animationController.value,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _floatingController,
                                        builder: (context, child) {
                                          return Transform.rotate(
                                            angle: math.sin(_floatingController.value * 2 * math.pi) * 0.1,
                                            child: const Text(
                                              '🎯',
                                              style: TextStyle(fontSize: 40),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Financial Goals',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Points Display
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          SFMSTheme.cartoonYellow,
                                          SFMSTheme.cartoonOrange,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: SFMSTheme.cartoonYellow.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Text(
                                          '⭐',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$userPoints',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          ' pts',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Quick Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      '🎰',
                                      'Lucky Draw',
                                      SFMSTheme.cartoonPink,
                                          () => widget.onNavigate('lucky-draw'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      '🎁',
                                      'Rewards Shop',
                                      SFMSTheme.cartoonPurple,
                                          () => widget.onNavigate('rewards-shop'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Goals Overview Card
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
                                  SFMSTheme.cartoonPurple.withOpacity(0.1),
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
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Total Goals Value',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(totalGoalsValue),
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2937),
                                            ),
                                            overflow: TextOverflow.ellipsis,  // ✅ 添加这行
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),  // ✅ 添加间距
                                    Flexible(  // ✅ 添加 Flexible
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Saved',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(totalSaved),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: SFMSTheme.successColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,  // ✅ 添加这行
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Progress Bar
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: totalGoalsValue > 0
                                        ? math.min(totalSaved / totalGoalsValue, 1.0)
                                        : 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            SFMSTheme.cartoonPurple,
                                            SFMSTheme.cartoonPink,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${totalGoalsValue > 0 ? ((totalSaved / totalGoalsValue) * 100).toInt() : 0}% Complete',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${activeGoals.length} Active Goals',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
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

                  // Active Goals Section
                  if (activeGoals.isNotEmpty) ...[
                    const Text(
                      'Active Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(activeGoals.length, (index) {
                      final goal = activeGoals[index];
                      final progress = _getProgressPercentage(goal.currentAmount, goal.targetAmount);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _getCategoryEmoji(goal.category),
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        if (goal.description.isNotEmpty)
                                          Text(
                                            goal.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getPriorityBackgroundColor(goal.priority),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    goal.priority.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getPriorityTextColor(goal.priority),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatCurrency(goal.currentAmount),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: SFMSTheme.cartoonPurple,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(goal.targetAmount),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Progress Bar
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getCategoryGradient(index),
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
                                  '${progress.toInt()}% Complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (goal.deadline.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        goal.deadline,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child:
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // ✅ 修改：显示自定义金额对话框
                                      setState(() {
                                        _selectedGoalId = goal.id;
                                        _showContributeDialog = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add_rounded, size: 20),
                                    label: const Text('Add Money'),  // ✅ 修改：改名
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SFMSTheme.cartoonPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Goal?'),
                                        content: Text('Delete "${goal.title}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      try {
                                        await context.read<AppProvider>().deleteGoal(goal.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Goal deleted! 🗑️'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.more_vert),
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    // Empty State
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎯',
                            style: TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No active goals yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first financial goal to get started!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Completed Goals Section
                  if (completedGoals.isNotEmpty) ...[
                    const Text(
                      'Completed Goals 🎉',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...completedGoals.map((goal) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(goal.targetAmount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${(goal.targetAmount * 0.1).toInt()}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 100), // Extra padding for bottom navigation
                ],
              );
            },
          ),
        ),

        // Modal overlay for Add Goal
        if (_showAddGoal)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Goal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Title',
                          hintText: 'e.g., New Car',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _targetAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target Amount (RM)',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _deadlineController,
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            _deadlineController.text = date.toIso8601String().split('T')[0];
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showAddGoal = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleAddGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SFMSTheme.cartoonPurple,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Create Goal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
            ),
          ),


        // ✅ 新增：自定义金额对话框
        if (_showContributeDialog)
          _buildContributeDialog(),
        // Floating Action Button for Add Goal
        Positioned(
          right: 16,
          bottom: 80, // Above bottom navigation
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _showAddGoal = true;
              });
            },
            backgroundColor: SFMSTheme.cartoonPurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      String emoji,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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

  Color _getPriorityBackgroundColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.yellow.shade100;
      case 'low':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getPriorityTextColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade800;
      case 'medium':
        return Colors.yellow.shade800;
      case 'low':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}