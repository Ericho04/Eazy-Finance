// ✅ FIXED: insight.dart - 使用 snake_case 匹配 Supabase 数据库

class Insight {
  final String id;
  final String userId;
  final String title;
  final String description;
  final InsightType type;
  final InsightCategory category;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Insight({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.data,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy with method for immutable updates
  Insight copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    InsightType? type,
    InsightCategory? category,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Insight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      data: data ?? Map<String, dynamic>.from(this.data),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  // ✅ 修复：toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // ✅ snake_case
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'data': data,
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'updated_at': updatedAt?.toIso8601String(),  // ✅ snake_case
      'is_active': isActive,  // ✅ snake_case
    };
  }

  // ✅ 修复：fromJson 读取 snake_case
  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // ✅ snake_case
      title: json['title'] as String,
      description: json['description'] as String,
      type: InsightType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => InsightType.summary,
      ),
      category: InsightCategory.values.firstWhere(
            (e) => e.toString().split('.').last == json['category'],
        orElse: () => InsightCategory.general,
      ),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,  // ✅ snake_case
      isActive: json['is_active'] as bool? ?? true,  // ✅ snake_case
    );
  }

  @override
  String toString() {
    return 'Insight(id: $id, title: $title, type: $type, category: $category, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Insight && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Insight types for different analysis
enum InsightType {
  trend,        // Spending/income trends
  prediction,   // Future projections
  comparison,   // Period comparisons
  alert,        // Warning/notifications
  recommendation, // AI suggestions
  achievement,  // Milestones reached
  summary,      // Periodic summaries
}

// Insight categories for organization
enum InsightCategory {
  spending,     // Expense insights
  income,       // Income insights
  budget,       // Budget performance
  goals,        // Goal progress
  savings,      // Savings insights
  debt,         // Debt management
  investment,   // Investment performance
  tax,          // Tax optimization
  cashflow,     // Cash flow analysis
  general,      // General financial health
}

// Spending trend insight data model
class SpendingTrendData {
  final String period; // 'weekly', 'monthly', 'yearly'
  final double currentAmount;
  final double previousAmount;
  final double changePercentage;
  final String category;
  final List<Map<String, dynamic>> chartData;

  SpendingTrendData({
    required this.period,
    required this.currentAmount,
    required this.previousAmount,
    required this.changePercentage,
    required this.category,
    required this.chartData,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'current_amount': currentAmount,  // ✅ snake_case
      'previous_amount': previousAmount,  // ✅ snake_case
      'change_percentage': changePercentage,  // ✅ snake_case
      'category': category,
      'chart_data': chartData,  // ✅ snake_case
    };
  }

  factory SpendingTrendData.fromJson(Map<String, dynamic> json) {
    return SpendingTrendData(
      period: json['period'] as String,
      currentAmount: (json['current_amount'] as num).toDouble(),  // ✅ snake_case
      previousAmount: (json['previous_amount'] as num).toDouble(),  // ✅ snake_case
      changePercentage: (json['change_percentage'] as num).toDouble(),  // ✅ snake_case
      category: json['category'] as String,
      chartData: List<Map<String, dynamic>>.from(json['chart_data'] as List? ?? []),  // ✅ snake_case
    );
  }
}

// Budget performance insight data model
class BudgetPerformanceData {
  final String period;
  final double budgetAmount;
  final double actualAmount;
  final double remainingAmount;
  final double utilizationPercentage;
  final List<String> topCategories;
  final Map<String, double> categoryBreakdown;

  BudgetPerformanceData({
    required this.period,
    required this.budgetAmount,
    required this.actualAmount,
    required this.remainingAmount,
    required this.utilizationPercentage,
    required this.topCategories,
    required this.categoryBreakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'budget_amount': budgetAmount,  // ✅ snake_case
      'actual_amount': actualAmount,  // ✅ snake_case
      'remaining_amount': remainingAmount,  // ✅ snake_case
      'utilization_percentage': utilizationPercentage,  // ✅ snake_case
      'top_categories': topCategories,  // ✅ snake_case
      'category_breakdown': categoryBreakdown,  // ✅ snake_case
    };
  }

  factory BudgetPerformanceData.fromJson(Map<String, dynamic> json) {
    return BudgetPerformanceData(
      period: json['period'] as String,
      budgetAmount: (json['budget_amount'] as num).toDouble(),  // ✅ snake_case
      actualAmount: (json['actual_amount'] as num).toDouble(),  // ✅ snake_case
      remainingAmount: (json['remaining_amount'] as num).toDouble(),  // ✅ snake_case
      utilizationPercentage: (json['utilization_percentage'] as num).toDouble(),  // ✅ snake_case
      topCategories: List<String>.from(json['top_categories'] as List? ?? []),  // ✅ snake_case
      categoryBreakdown: Map<String, double>.from(
        (json['category_breakdown'] as Map? ?? {}).map(  // ✅ snake_case
              (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
    );
  }
}

// Goal progress insight data model
class GoalProgressData {
  final String goalId;
  final String goalTitle;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final int daysRemaining;
  final double requiredMonthlySaving;
  final bool isOnTrack;
  final String projectedCompletionDate;

  GoalProgressData({
    required this.goalId,
    required this.goalTitle,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.daysRemaining,
    required this.requiredMonthlySaving,
    required this.isOnTrack,
    required this.projectedCompletionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'goal_id': goalId,  // ✅ snake_case
      'goal_title': goalTitle,  // ✅ snake_case
      'target_amount': targetAmount,  // ✅ snake_case
      'current_amount': currentAmount,  // ✅ snake_case
      'progress_percentage': progressPercentage,  // ✅ snake_case
      'days_remaining': daysRemaining,  // ✅ snake_case
      'required_monthly_saving': requiredMonthlySaving,  // ✅ snake_case
      'is_on_track': isOnTrack,  // ✅ snake_case
      'projected_completion_date': projectedCompletionDate,  // ✅ snake_case
    };
  }

  factory GoalProgressData.fromJson(Map<String, dynamic> json) {
    return GoalProgressData(
      goalId: json['goal_id'] as String,  // ✅ snake_case
      goalTitle: json['goal_title'] as String,  // ✅ snake_case
      targetAmount: (json['target_amount'] as num).toDouble(),  // ✅ snake_case
      currentAmount: (json['current_amount'] as num).toDouble(),  // ✅ snake_case
      progressPercentage: (json['progress_percentage'] as num).toDouble(),  // ✅ snake_case
      daysRemaining: json['days_remaining'] as int,  // ✅ snake_case
      requiredMonthlySaving: (json['required_monthly_saving'] as num).toDouble(),  // ✅ snake_case
      isOnTrack: json['is_on_track'] as bool,  // ✅ snake_case
      projectedCompletionDate: json['projected_completion_date'] as String,  // ✅ snake_case
    );
  }
}

// Cash flow insight data model
class CashFlowData {
  final String period;
  final double totalIncome;
  final double totalExpenses;
  final double netCashFlow;
  final double savingsRate;
  final List<Map<String, dynamic>> monthlyTrends;
  final Map<String, double> incomeBySource;
  final Map<String, double> expensesByCategory;

  CashFlowData({
    required this.period,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.savingsRate,
    required this.monthlyTrends,
    required this.incomeBySource,
    required this.expensesByCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'total_income': totalIncome,  // ✅ snake_case
      'total_expenses': totalExpenses,  // ✅ snake_case
      'net_cash_flow': netCashFlow,  // ✅ snake_case
      'savings_rate': savingsRate,  // ✅ snake_case
      'monthly_trends': monthlyTrends,  // ✅ snake_case
      'income_by_source': incomeBySource,  // ✅ snake_case
      'expenses_by_category': expensesByCategory,  // ✅ snake_case
    };
  }

  factory CashFlowData.fromJson(Map<String, dynamic> json) {
    return CashFlowData(
      period: json['period'] as String,
      totalIncome: (json['total_income'] as num).toDouble(),  // ✅ snake_case
      totalExpenses: (json['total_expenses'] as num).toDouble(),  // ✅ snake_case
      netCashFlow: (json['net_cash_flow'] as num).toDouble(),  // ✅ snake_case
      savingsRate: (json['savings_rate'] as num).toDouble(),  // ✅ snake_case
      monthlyTrends: List<Map<String, dynamic>>.from(json['monthly_trends'] as List? ?? []),  // ✅ snake_case
      incomeBySource: Map<String, double>.from(
        (json['income_by_source'] as Map? ?? {}).map(  // ✅ snake_case
              (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      expensesByCategory: Map<String, double>.from(
        (json['expenses_by_category'] as Map? ?? {}).map(  // ✅ snake_case
              (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
    );
  }
}

// Insight utility class for generating insights
class InsightUtils {
  // Generate spending trend insight
  static Insight createSpendingTrendInsight({
    required String userId,
    required SpendingTrendData data,
  }) {
    final isIncreasing = data.changePercentage > 0;
    final title = isIncreasing
        ? 'Spending Increased in ${data.category}'
        : 'Spending Decreased in ${data.category}';

    final description = isIncreasing
        ? 'Your ${data.category.toLowerCase()} spending increased by ${data.changePercentage.abs().toStringAsFixed(1)}% this ${data.period}.'
        : 'Great job! Your ${data.category.toLowerCase()} spending decreased by ${data.changePercentage.abs().toStringAsFixed(1)}% this ${data.period}.';

    return Insight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      type: InsightType.trend,
      category: InsightCategory.spending,
      data: data.toJson(),
    );
  }

  // Generate budget performance insight
  static Insight createBudgetPerformanceInsight({
    required String userId,
    required BudgetPerformanceData data,
  }) {
    final isOverBudget = data.utilizationPercentage > 100;
    final title = isOverBudget
        ? 'Budget Exceeded'
        : data.utilizationPercentage > 80
        ? 'Budget Alert: ${data.utilizationPercentage.toStringAsFixed(0)}% Used'
        : 'Budget On Track';

    final description = isOverBudget
        ? 'You\'ve exceeded your ${data.period} budget by RM ${(data.actualAmount - data.budgetAmount).toStringAsFixed(2)}.'
        : 'You\'ve used ${data.utilizationPercentage.toStringAsFixed(0)}% of your ${data.period} budget with RM ${data.remainingAmount.toStringAsFixed(2)} remaining.';

    return Insight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      type: isOverBudget ? InsightType.alert : InsightType.summary,
      category: InsightCategory.budget,
      data: data.toJson(),
    );
  }

  // Generate goal progress insight
  static Insight createGoalProgressInsight({
    required String userId,
    required GoalProgressData data,
  }) {
    final title = data.isOnTrack
        ? '${data.goalTitle} is On Track'
        : '${data.goalTitle} Needs Attention';

    final description = data.isOnTrack
        ? 'You\'re ${data.progressPercentage.toStringAsFixed(0)}% towards your ${data.goalTitle} goal. Keep it up!'
        : 'To reach your ${data.goalTitle} goal on time, you need to save RM ${data.requiredMonthlySaving.toStringAsFixed(2)} monthly.';

    return Insight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      type: data.isOnTrack ? InsightType.achievement : InsightType.recommendation,
      category: InsightCategory.goals,
      data: data.toJson(),
    );
  }

  // Generate cash flow insight
  static Insight createCashFlowInsight({
    required String userId,
    required CashFlowData data,
  }) {
    final isPositive = data.netCashFlow > 0;
    final title = isPositive
        ? 'Positive Cash Flow'
        : 'Negative Cash Flow';

    final description = isPositive
        ? 'Your ${data.period} cash flow is positive at RM ${data.netCashFlow.toStringAsFixed(2)} with a ${data.savingsRate.toStringAsFixed(1)}% savings rate.'
        : 'Your ${data.period} cash flow is negative at RM ${data.netCashFlow.toStringAsFixed(2)}. Consider reviewing your expenses.';

    return Insight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      type: isPositive ? InsightType.achievement : InsightType.alert,
      category: InsightCategory.cashflow,
      data: data.toJson(),
    );
  }

  // Generate financial health insight
  static Insight createFinancialHealthInsight({
    required String userId,
    required double netWorth,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double savingsRate,
  }) {
    final isHealthy = savingsRate >= 20 && (monthlyIncome - monthlyExpenses) > 0;
    final title = isHealthy
        ? 'Strong Financial Health'
        : 'Financial Health Needs Attention';

    final description = isHealthy
        ? 'Great job! Your ${savingsRate.toStringAsFixed(1)}% savings rate and positive cash flow indicate strong financial health.'
        : 'Consider reviewing your expenses. Your current savings rate is ${savingsRate.toStringAsFixed(1)}%, aim for at least 20%.';

    return Insight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      type: isHealthy ? InsightType.achievement : InsightType.recommendation,
      category: InsightCategory.general,
      data: {
        'net_worth': netWorth,  // ✅ snake_case
        'monthly_income': monthlyIncome,  // ✅ snake_case
        'monthly_expenses': monthlyExpenses,  // ✅ snake_case
        'savings_rate': savingsRate,  // ✅ snake_case
      },
    );
  }

  // Generate category spending insight
  static Insight createCategorySpendingInsight({
    required String userId,
    required Map<String, double> categorySpending,
    required String period,
  }) {
    if (categorySpending.isEmpty) {
      return Insight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: 'No Spending Data',
        description: 'Start tracking your expenses to get personalized insights.',
        type: InsightType.summary,
        category: InsightCategory.spending,
        data: {},
      );
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.first;
    final totalSpending = categorySpending.values.reduce((a, b) => a + b);
    final topCategoryPercentage = (topCategory.value / totalSpending) * 100;

    final title = 'Top Spending: ${topCategory.key}';
    final description = 'Your highest spending category this $period is ${topCategory.key} at RM ${topCategory.value.toStringAsFixed(2)} (${topCategoryPercentage.toStringAsFixed(0)}% of total spending).';

    return Insight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      type: InsightType.summary,
      category: InsightCategory.spending,
      data: {
        'period': period,
        'top_category': topCategory.key,  // ✅ snake_case
        'top_category_amount': topCategory.value,  // ✅ snake_case
        'top_category_percentage': topCategoryPercentage,  // ✅ snake_case
        'total_spending': totalSpending,  // ✅ snake_case
        'category_breakdown': categorySpending,  // ✅ snake_case
      },
    );
  }
}