// ✅ FIXED: budget.dart - 使用 snake_case 匹配 Supabase 数据库

class Budget {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double spent;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final BudgetStatus status;
  final List<String> tags;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.spent = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
    this.status = BudgetStatus.active,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate remaining budget amount
  double get remainingAmount {
    final remaining = amount - spent;
    return remaining < 0 ? 0 : remaining;
  }

  // Calculate utilization percentage
  double get utilizationPercentage {
    if (amount <= 0) return 0.0;
    return (spent / amount) * 100;
  }

  // Check if budget is exceeded
  bool get isExceeded {
    return spent > amount;
  }

  // Calculate days remaining in period
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Check if budget period is active
  bool get isPeriodActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Calculate daily spending allowance
  double get dailyAllowance {
    final remaining = remainingAmount;
    final days = daysRemaining;
    if (days <= 0) return 0;
    return remaining / days;
  }

  // Get budget health status
  BudgetHealth get healthStatus {
    final utilization = utilizationPercentage;
    if (utilization >= 100) return BudgetHealth.critical;
    if (utilization >= 80) return BudgetHealth.warning;
    if (utilization >= 60) return BudgetHealth.moderate;
    return BudgetHealth.good;
  }

  // Copy with method for immutable updates
  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    double? spent,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    BudgetStatus? status,
    List<String>? tags,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      tags: tags ?? List.from(this.tags),
    );
  }

  // Add spending to budget
  Budget addSpending(double expenseAmount) {
    return copyWith(
      spent: spent + expenseAmount,
      updatedAt: DateTime.now(),
    );
  }

  // Remove spending from budget
  Budget removeSpending(double expenseAmount) {
    final newSpent = spent - expenseAmount;
    return copyWith(
      spent: newSpent < 0 ? 0 : newSpent,
      updatedAt: DateTime.now(),
    );
  }

  // Reset budget spending
  Budget resetSpending() {
    return copyWith(
      spent: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  // ✅ 修复：toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // ✅ snake_case
      'category': category,
      'amount': amount,
      'spent': spent,
      'period': period.toString().split('.').last,
      'start_date': startDate.toIso8601String(),  // ✅ snake_case
      'end_date': endDate.toIso8601String(),  // ✅ snake_case
      'is_active': isActive,  // ✅ snake_case
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'updated_at': updatedAt?.toIso8601String(),  // ✅ snake_case
      'status': status.toString().split('.').last,
      'tags': tags,
    };
  }

  // ✅ 修复：fromJson 读取 snake_case
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // ✅ snake_case
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      period: BudgetPeriod.values.firstWhere(
            (e) => e.toString().split('.').last == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(json['start_date'] as String),  // ✅ snake_case
      endDate: DateTime.parse(json['end_date'] as String),  // ✅ snake_case
      isActive: json['is_active'] as bool? ?? true,  // ✅ snake_case
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,  // ✅ snake_case
      status: BudgetStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => BudgetStatus.active,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, category: $category, amount: $amount, spent: $spent, period: $period, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Budget period enumeration
enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  custom,
}

// Budget status enumeration
enum BudgetStatus {
  active,
  paused,
  completed,
  cancelled,
}

// Budget health status enumeration
enum BudgetHealth {
  good,
  moderate,
  warning,
  critical,
}

// Budget category predefined list
class BudgetCategory {
  static const String food = 'Food & Dining';
  static const String transportation = 'Transportation';
  static const String shopping = 'Shopping';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills & Utilities';
  static const String healthcare = 'Healthcare';
  static const String education = 'Education';
  static const String travel = 'Travel';
  static const String groceries = 'Groceries';
  static const String fuel = 'Fuel';
  static const String clothing = 'Clothing';
  static const String gifts = 'Gifts & Donations';
  static const String investment = 'Investment';
  static const String savings = 'Savings';
  static const String other = 'Other';

  static List<String> get allCategories => [
    food,
    transportation,
    shopping,
    entertainment,
    bills,
    healthcare,
    education,
    travel,
    groceries,
    fuel,
    clothing,
    gifts,
    investment,
    savings,
    other,
  ];

  static Map<String, String> get categoryEmojis => {
    food: '🍽️',
    transportation: '🚗',
    shopping: '🛍️',
    entertainment: '🎮',
    bills: '🏠',
    healthcare: '❤️',
    education: '📚',
    travel: '✈️',
    groceries: '🛒',
    fuel: '⛽',
    clothing: '👕',
    gifts: '🎁',
    investment: '📈',
    savings: '💰',
    other: '💳',
  };

  static String getCategoryEmoji(String category) {
    return categoryEmojis[category] ?? '💳';
  }
}

// Budget utility functions
class BudgetUtils {
  // Calculate budget period dates
  static Map<String, DateTime> calculatePeriodDates(
      BudgetPeriod period, {
        DateTime? startDate,
      }) {
    final start = startDate ?? DateTime.now();
    DateTime end;

    switch (period) {
      case BudgetPeriod.daily:
        end = DateTime(start.year, start.month, start.day, 23, 59, 59);
        break;
      case BudgetPeriod.weekly:
        final daysUntilSunday = (7 - start.weekday) % 7;
        end = start.add(Duration(days: daysUntilSunday));
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
        break;
      case BudgetPeriod.monthly:
        end = DateTime(start.year, start.month + 1, 0, 23, 59, 59);
        break;
      case BudgetPeriod.quarterly:
        final quarterEnd = ((start.month - 1) ~/ 3 + 1) * 3;
        end = DateTime(start.year, quarterEnd + 1, 0, 23, 59, 59);
        break;
      case BudgetPeriod.yearly:
        end = DateTime(start.year, 12, 31, 23, 59, 59);
        break;
      case BudgetPeriod.custom:
        end = start.add(const Duration(days: 30)); // Default 30 days
        break;
    }

    return {
      'startDate': start,
      'endDate': end,
    };
  }

  // Get period label
  static String getPeriodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom';
    }
  }

  // Get status color
  static String getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.active:
        return '#4CAF50'; // Green
      case BudgetStatus.paused:
        return '#FF9800'; // Orange
      case BudgetStatus.completed:
        return '#2196F3'; // Blue
      case BudgetStatus.cancelled:
        return '#F44336'; // Red
    }
  }

  // Get health color
  static String getHealthColor(BudgetHealth health) {
    switch (health) {
      case BudgetHealth.good:
        return '#4CAF50'; // Green
      case BudgetHealth.moderate:
        return '#8BC34A'; // Light Green
      case BudgetHealth.warning:
        return '#FF9800'; // Orange
      case BudgetHealth.critical:
        return '#F44336'; // Red
    }
  }

  // Create default budget for category
  static Budget createDefaultBudget({
    required String userId,
    required String category,
    required double amount,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) {
    final dates = calculatePeriodDates(period);

    return Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      category: category,
      amount: amount,
      period: period,
      startDate: dates['startDate']!,
      endDate: dates['endDate']!,
    );
  }

  // Check if budget needs renewal
  static bool needsRenewal(Budget budget) {
    final now = DateTime.now();
    return now.isAfter(budget.endDate) && budget.isActive;
  }

  // Renew budget for next period
  static Budget renewBudget(Budget budget) {
    final dates = calculatePeriodDates(budget.period);

    return budget.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: dates['startDate'],
      endDate: dates['endDate'],
      spent: 0.0,
      status: BudgetStatus.active,
      updatedAt: DateTime.now(),
    );
  }

  // Calculate budget recommendations based on spending history
  static double calculateRecommendedAmount({
    required List<double> historicalSpending,
    double buffer = 0.1, // 10% buffer
  }) {
    if (historicalSpending.isEmpty) return 0.0;

    final averageSpending = historicalSpending.reduce((a, b) => a + b) / historicalSpending.length;
    return averageSpending * (1 + buffer);
  }
}