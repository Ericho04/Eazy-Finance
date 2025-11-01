import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  double _getProgressPercentage(double current, double target) {
    return math.min((current / target) * 100, 100);
  }

  String _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return 'high';
      case 'medium':
        return 'medium';
      case 'low':
        return 'low';
      default:
        return 'medium';
    }
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'demo-user-123',
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
    return Scaffold(
      body: Stack(
        children: [
          // Main content
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
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$userPoints',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'points',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
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
                                      child: GestureDetector(
                                        onTap: () => widget.onNavigate('lucky-draw'),
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                SFMSTheme.cartoonPink,
                                                SFMSTheme.cartoonPurple,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: SFMSTheme.cartoonPink.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Lucky Draw',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => widget.onNavigate('rewards-shop'),
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                SFMSTheme.cartoonBlue,
                                                SFMSTheme.cartoonCyan,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: SFMSTheme.cartoonBlue.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Shop',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Color(0xFFF0F9FF)],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              SFMSTheme.successColor,
                                              SFMSTheme.successColor.withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.trending_up,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Goals Progress',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            Text(
                                              'Your financial journey',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatCurrency(totalSaved),
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            const Text(
                                              'Total Saved',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _formatCurrency(totalGoalsValue),
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            const Text(
                                              'Target Amount',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Progress bar
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Overall Progress',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${totalGoalsValue > 0 ? ((totalSaved / totalGoalsValue) * 100).toInt() : 0}%',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: totalGoalsValue > 0 ? totalSaved / totalGoalsValue : 0,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          SFMSTheme.successColor,
                                        ),
                                        minHeight: 8,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${completedGoals.length} completed',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          Text(
                                            '${activeGoals.length} active goals',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF845EC2),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Active Goals',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAddGoal = true;
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text(
                            'Add Goal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SFMSTheme.cartoonPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active Goals List
                    if (activeGoals.isEmpty)
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
                            const Text('🎯', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              'No active goals yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start by creating your first financial goal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: activeGoals.asMap().entries.map((entry) {
                          final index = entry.key;
                          final goal = entry.value;
                          final progress = _getProgressPercentage(goal.currentAmount, goal.targetAmount);

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
                                      gradient: const LinearGradient(
                                        colors: [Colors.white, Color(0xFFFAF5FF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
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
                                                  _getCategoryEmoji(goal.category),
                                                  style: const TextStyle(fontSize: 24),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
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
                                                    goal.description,
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
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getPriorityBackgroundColor(goal.priority),
                                                    borderRadius: BorderRadius.circular(8),
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
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${(goal.targetAmount / 100).toInt()} pts',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.amber,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              _formatCurrency(goal.targetAmount),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        LinearProgressIndicator(
                                          value: progress / 100,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getCategoryGradient(index).first,
                                          ),
                                          minHeight: 6,
                                        ),
                                        const SizedBox(height: 12),

                                        // Actions
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (goal.deadline.isNotEmpty)
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 12,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    DateFormat('MMM dd').format(DateTime.parse(goal.deadline)),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              const SizedBox(),

                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () => _handleContributeToGoal(goal.id, 100),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: SFMSTheme.successColor,
                                                    elevation: 0,
                                                    minimumSize: const Size(60, 32),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '+RM100',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () => _handleContributeToGoal(goal.id, 500),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: SFMSTheme.cartoonBlue,
                                                    elevation: 0,
                                                    minimumSize: const Size(60, 32),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '+RM500',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
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

                    // Completed Goals
                    if (completedGoals.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Completed Goals',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        children: completedGoals.take(3).map((goal) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getCategoryEmoji(goal.category),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            goal.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Completed',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (goal.completedAt != null)
                                        Text(
                                          'Completed on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(goal.completedAt!))}',
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
                                      _formatCurrency(goal.targetAmount),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${(goal.targetAmount / 100).toInt()} pts',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
        ],
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