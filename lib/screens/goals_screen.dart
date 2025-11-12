import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sfms_flutter/providers/auth_provider.dart';
import 'dart:math' as math;

import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
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

  Future<void> _handleContribute(BuildContext context) async {
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

  Widget _buildContributeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Money',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showContributeDialog = false;
                        _contributeController.clear();
                      });
                    },
                    icon: Icon(Icons.close, color: textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _contributeController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: TextStyle(color: textSecondary),
                  prefixText: 'RM ',
                  prefixStyle: TextStyle(color: textPrimary),
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
                  onPressed: () => _handleContribute(context),
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
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextMuted : SFMSTheme.textMuted;
    final cardColor = isDarkMode ? SFMSTheme.darkCardBg : SFMSTheme.cardColor;
    final cardShadow = isDarkMode ? SFMSTheme.darkCardShadow : SFMSTheme.softCardShadow;
    final successColor = isDarkMode ? SFMSTheme.darkAccentEmerald : SFMSTheme.successColor;
    final neutralLight = isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.neutralLight;
    final neutralMedium = isDarkMode ? SFMSTheme.darkBgTertiary : SFMSTheme.neutralMedium;
    final borderColor = isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade200;

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
                                      Text(
                                        'Financial Goals',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
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
                                      context,
                                      '🎰',
                                      'Lucky Draw',
                                      SFMSTheme.cartoonPink,
                                          () => widget.onNavigate('lucky-draw'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      context,
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
                                colors: isDarkMode
                                  ? [
                                      SFMSTheme.darkCardBg,
                                      SFMSTheme.darkBgTertiary.withOpacity(0.5),
                                    ]
                                  : [
                                      Colors.white,
                                      SFMSTheme.cartoonPurple.withOpacity(0.1),
                                    ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: cardShadow,
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
                                          Text(
                                            'Total Goals Value',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textSecondary,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(totalGoalsValue),
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Saved',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textSecondary,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(totalSaved),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: successColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                                    color: neutralMedium,
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
                                          colors: isDarkMode
                                            ? [SFMSTheme.darkAccentTeal, SFMSTheme.darkAccentEmerald]
                                            : [SFMSTheme.cartoonPurple, SFMSTheme.cartoonPink],
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
                                        color: textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '${activeGoals.length} Active Goals',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
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
                    Text(
                      'Active Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
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
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                          boxShadow: cardShadow,
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
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        if (goal.description.isNotEmpty)
                                          Text(
                                            goal.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getPriorityBackgroundColor(context, goal.priority),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    goal.priority.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getPriorityTextColor(context, goal.priority),
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
                                    color: isDarkMode ? SFMSTheme.darkAccentTeal : SFMSTheme.cartoonPurple,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(goal.targetAmount),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Progress Bar
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: neutralMedium,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getCategoryGradient(context, index),
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
                                    color: textSecondary,
                                  ),
                                ),
                                if (goal.deadline.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        goal.deadline,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
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
                                      setState(() {
                                        _selectedGoalId = goal.id;
                                        _showContributeDialog = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add_rounded, size: 20),
                                    label: const Text('Add Money'),
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
                                        backgroundColor: cardColor,
                                        title: Text('Delete Goal?', style: TextStyle(color: textPrimary)),
                                        content: Text('Delete "${goal.title}"?', style: TextStyle(color: textSecondary)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text('Cancel', style: TextStyle(color: textSecondary)),
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
                                  color: textSecondary,
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
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: borderColor,
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
                          Text(
                            'No active goals yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first financial goal to get started!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Completed Goals Section
                  if (completedGoals.isNotEmpty) ...[
                    Text(
                      'Completed Goals 🎉',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...completedGoals.map((goal) {
                      final completedBg = isDarkMode ? SFMSTheme.darkAccentEmerald.withOpacity(0.2) : Colors.green.shade50;
                      final completedBorder = isDarkMode ? SFMSTheme.darkAccentEmerald.withOpacity(0.3) : Colors.green.shade200;
                      final completedIconBg = isDarkMode ? SFMSTheme.darkAccentEmerald.withOpacity(0.3) : Colors.green.shade100;
                      final completedIcon = isDarkMode ? SFMSTheme.darkAccentEmerald : Colors.green;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: completedBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: completedBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: completedIconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: completedIcon,
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(goal.targetAmount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDarkMode ? SFMSTheme.cartoonYellow.withOpacity(0.3) : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: isDarkMode ? SFMSTheme.cartoonYellow : Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${(goal.targetAmount * 0.1).toInt()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDarkMode ? SFMSTheme.cartoonYellow : Colors.amber,
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
                  color: cardColor,
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
                      Text(
                        'Create New Goal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Goal Title',
                          labelStyle: TextStyle(color: textSecondary),
                          hintText: 'e.g., New Car',
                          hintStyle: TextStyle(color: textMuted),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _descriptionController,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: textSecondary),
                          hintText: 'Brief description',
                          hintStyle: TextStyle(color: textMuted),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _targetAmountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Target Amount (RM)',
                          labelStyle: TextStyle(color: textSecondary),
                          hintText: '0',
                          hintStyle: TextStyle(color: textMuted),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _deadlineController,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Deadline',
                          labelStyle: TextStyle(color: textSecondary),
                          hintText: 'YYYY-MM-DD',
                          hintStyle: TextStyle(color: textMuted),
                          border: const OutlineInputBorder(),
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
                                backgroundColor: neutralMedium,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: textPrimary,
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

        // Contribute Dialog
        if (_showContributeDialog)
          _buildContributeDialog(context),

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
      BuildContext context,
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

  List<Color> _getCategoryGradient(BuildContext context, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    if (isDarkMode) {
      final gradients = [
        [SFMSTheme.darkAccentTeal, SFMSTheme.darkAccentEmerald],
        [SFMSTheme.trustPrimary, SFMSTheme.trustHighlight],
        [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
        [SFMSTheme.cartoonCyan, const Color(0xFF66E7FF)],
        [SFMSTheme.cartoonMint, const Color(0xFFA0FFE6)],
        [SFMSTheme.cartoonYellow, const Color(0xFFFFE066)],
        [SFMSTheme.cartoonOrange, const Color(0xFFFFAB66)],
      ];
      return gradients[index % gradients.length];
    } else {
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

  Color _getPriorityBackgroundColor(BuildContext context, String priority) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    switch (priority) {
      case 'high':
        return isDarkMode ? SFMSTheme.dangerColor.withOpacity(0.2) : Colors.red.shade100;
      case 'medium':
        return isDarkMode ? SFMSTheme.warningColor.withOpacity(0.2) : Colors.yellow.shade100;
      case 'low':
        return isDarkMode ? SFMSTheme.successColor.withOpacity(0.2) : Colors.green.shade100;
      default:
        return isDarkMode ? SFMSTheme.darkBgTertiary : Colors.grey.shade100;
    }
  }

  Color _getPriorityTextColor(BuildContext context, String priority) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    switch (priority) {
      case 'high':
        return isDarkMode ? SFMSTheme.darkAccentCoral : Colors.red.shade800;
      case 'medium':
        return isDarkMode ? SFMSTheme.warningColor : Colors.yellow.shade800;
      case 'low':
        return isDarkMode ? SFMSTheme.darkAccentEmerald : Colors.green.shade800;
      default:
        return isDarkMode ? SFMSTheme.darkTextSecondary : Colors.grey.shade800;
    }
  }
}
