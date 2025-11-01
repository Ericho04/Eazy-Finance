import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../providers/app_provider.dart';
import '../utils/theme.dart';

class InsightsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const InsightsScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  String _timeRange = 'month';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animationController.forward();
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
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
          final categoryBreakdown = appProvider.getCategoryBreakdown();
          final totalSpending = categoryBreakdown.values.fold(0.0, (a, b) => a + b);
          final monthlySpending = _getSampleSpendingData();
          
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
                            animation: _floatingController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + math.sin(_floatingController.value * 2 * math.pi) * 0.05,
                                child: const Text(
                                  '📊',
                                  style: TextStyle(fontSize: 40),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Financial Insights',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  'Your spending patterns and financial tools',
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Time Range Selector
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['week', 'month', 'year'].map((range) {
                          final isActive = _timeRange == range;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _timeRange = range;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? SFMSTheme.cartoonBlue
                                      : Colors.white,
                                  foregroundColor: isActive
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isActive 
                                          ? SFMSTheme.cartoonBlue 
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  range.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Spending Overview
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
                                AnimatedBuilder(
                                  animation: _floatingController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _floatingController.value * 2 * math.pi,
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              SFMSTheme.cartoonBlue,
                                              SFMSTheme.cartoonPurple,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: const Icon(
                                          Icons.trending_up,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Monthly Overview',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      Text(
                                        'Your spending breakdown',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatCurrency(totalSpending),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const Text(
                                      'Total spent this month',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('📈', style: TextStyle(fontSize: 32)),
                                    Text(
                                      _getSpendingInsight(totalSpending),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
              
              // Category Breakdown
              const Row(
                children: [
                  Icon(
                    Icons.pie_chart,
                    color: Color(0xFF845EC2),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Spending by Category',
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
                children: monthlySpending.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (70 + index * 20) * (1 - _animationController.value)),
                        child: Opacity(
                          opacity: _animationController.value,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFFAF5FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category['category'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(category['amount'] as double),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${category['percentage']}%',
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
                                            color: (category['trend'] as String).startsWith('+')
                                                ? Colors.red.shade100
                                                : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            category['trend'] as String,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: (category['trend'] as String).startsWith('+')
                                                  ? Colors.red.shade800
                                                  : Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                LinearProgressIndicator(
                                  value: (category['percentage'] as int) / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getCategoryColor(index),
                                  ),
                                  minHeight: 6,
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
              
              // Financial Tools Section
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF4E8EF7),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Financial Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _financialTools.length,
                itemBuilder: (context, index) {
                  final tool = _financialTools[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (80 + index * 20) * (1 - _animationController.value)),
                        child: Opacity(
                          opacity: _animationController.value,
                          child: GestureDetector(
                            onTap: () => widget.onNavigate(tool['route'] as String),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: tool['colors'] as List<Color>,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (tool['colors'] as List<Color>).first.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Background decoration
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: Opacity(
                                      opacity: 0.2,
                                      child: Icon(
                                        tool['icon'] as IconData,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  
                                  // Content
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          tool['icon'] as IconData,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          tool['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tool['description'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Row(
                                          children: [
                                            Text(
                                              'Explore',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onNavigate('reports'),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [SFMSTheme.cartoonBlue, SFMSTheme.cartoonCyan],
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
                            Icon(Icons.bar_chart, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reports',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Detailed analysis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onNavigate('expense-history'),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [SFMSTheme.cartoonPurple, SFMSTheme.cartoonPink],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: SFMSTheme.cartoonPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'History',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'View transactions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
              const SizedBox(height: 24),
              
              // AI Insights Card
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0F2FF), Color(0xFFF8F9FF)],
                          ),
                          borderRadius: BorderRadius.circular(24),
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
                                AnimatedBuilder(
                                  animation: _floatingController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _floatingController.value * 2 * math.pi,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              SFMSTheme.aiColor,
                                              SFMSTheme.aiColor.withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'AI Insights',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: SFMSTheme.aiColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text('🤖', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '💡 Smart Tip',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Based on your spending patterns, consider setting up automatic savings to reach your financial goals faster!",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
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
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100), // Extra padding for bottom navigation
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleSpendingData() {
    return [
      {
        'category': 'Food & Dining',
        'amount': 450.0,
        'percentage': 35,
        'trend': '+12%',
      },
      {
        'category': 'Transportation',
        'amount': 280.0,
        'percentage': 22,
        'trend': '-5%',
      },
      {
        'category': 'Shopping',
        'amount': 320.0,
        'percentage': 25,
        'trend': '+8%',
      },
      {
        'category': 'Entertainment',
        'amount': 150.0,
        'percentage': 12,
        'trend': '-2%',
      },
      {
        'category': 'Others',
        'amount': 80.0,
        'percentage': 6,
        'trend': '+3%',
      },
    ];
  }

  String _getSpendingInsight(double amount) {
    if (amount > 1000) {
      return 'High spending month';
    } else if (amount > 500) {
      return 'Moderate spending';
    } else {
      return 'Great spending control!';
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      SFMSTheme.cartoonPink,
      SFMSTheme.cartoonPurple,
      SFMSTheme.cartoonBlue,
      SFMSTheme.cartoonCyan,
      SFMSTheme.cartoonMint,
    ];
    return colors[index % colors.length];
  }
}

final List<Map<String, dynamic>> _financialTools = [
  {
    'title': 'Debt Manager',
    'description': 'Track and manage your debts',
    'icon': Icons.credit_card,
    'colors': [SFMSTheme.dangerColor, const Color(0xFFFF8A65)],
    'route': 'financial-debts',
  },
  {
    'title': 'Accounts',
    'description': 'Manage your bank accounts',
    'icon': Icons.account_balance,
    'colors': [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
    'route': 'financial-accounts',
  },
  {
    'title': 'Financial Goals',
    'description': 'Set and track financial targets',
    'icon': Icons.flag,
    'colors': [SFMSTheme.successColor, const Color(0xFF81C784)],
    'route': 'financial-goals',
  },
  {
    'title': 'Tax Planning',
    'description': 'Plan your tax obligations',
    'icon': Icons.receipt_long,
    'colors': [SFMSTheme.cartoonPurple, const Color(0xFFB39BC8)],
    'route': 'financial-tax',
  },
];