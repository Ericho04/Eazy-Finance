// Insight model for financial analytics and reporting
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

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: InsightCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
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
      'currentAmount': currentAmount,
      'previousAmount': previousAmount,
      'changePercentage': changePercentage,
      'category': category,
      'chartData': chartData,
    };
  }

  factory SpendingTrendData.fromJson(Map<String, dynamic> json) {
    return SpendingTrendData(
      period: json['period'] as String,
      currentAmount: (json['currentAmount'] as num).toDouble(),
      previousAmount: (json['previousAmount'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
      category: json['category'] as String,
      chartData: List<Map<String, dynamic>>.from(json['chartData'] as List),
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
      'budgetAmount': budgetAmount,
      'actualAmount': actualAmount,
      'remainingAmount': remainingAmount,
      'utilizationPercentage': utilizationPercentage,
      'topCategories': topCategories,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  factory BudgetPerformanceData.fromJson(Map<String, dynamic> json) {
    return BudgetPerformanceData(
      period: json['period'] as String,
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      actualAmount: (json['actualAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      utilizationPercentage: (json['utilizationPercentage'] as num).toDouble(),
      topCategories: List<String>.from(json['topCategories'] as List),
      categoryBreakdown: Map<String, double>.from(
        (json['categoryBreakdown'] as Map).map(
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
      'goalId': goalId,
      'goalTitle': goalTitle,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'progressPercentage': progressPercentage,
      'daysRemaining': daysRemaining,
      'requiredMonthlySaving': requiredMonthlySaving,
      'isOnTrack': isOnTrack,
      'projectedCompletionDate': projectedCompletionDate,
    };
  }

  factory GoalProgressData.fromJson(Map<String, dynamic> json) {
    return GoalProgressData(
      goalId: json['goalId'] as String,
      goalTitle: json['goalTitle'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      daysRemaining: json['daysRemaining'] as int,
      requiredMonthlySaving: (json['requiredMonthlySaving'] as num).toDouble(),
      isOnTrack: json['isOnTrack'] as bool,
      projectedCompletionDate: json['projectedCompletionDate'] as String,
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
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netCashFlow': netCashFlow,
      'savingsRate': savingsRate,
      'monthlyTrends': monthlyTrends,
      'incomeBySource': incomeBySource,
      'expensesByCategory': expensesByCategory,
    };
  }

  factory CashFlowData.fromJson(Map<String, dynamic> json) {
    return CashFlowData(
      period: json['period'] as String,
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netCashFlow: (json['netCashFlow'] as num).toDouble(),
      savingsRate: (json['savingsRate'] as num).toDouble(),
      monthlyTrends: List<Map<String, dynamic>>.from(json['monthlyTrends'] as List),
      incomeBySource: Map<String, double>.from(
        (json['incomeBySource'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      expensesByCategory: Map<String, double>.from(
        (json['expensesByCategory'] as Map).map(
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
}