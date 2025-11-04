import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final int year;
  final int month;
  final double monthlyIncome;
  final DateTime createdAt;
  final List<BudgetCapEntity> caps;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.monthlyIncome,
    required this.createdAt,
    this.caps = const [],
  });

  @override
  List<Object?> get props => [id, userId, year, month, monthlyIncome, createdAt, caps];

  BudgetEntity copyWith({
    String? id,
    String? userId,
    int? year,
    int? month,
    double? monthlyIncome,
    DateTime? createdAt,
    List<BudgetCapEntity>? caps,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      month: month ?? this.month,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      createdAt: createdAt ?? this.createdAt,
      caps: caps ?? this.caps,
    );
  }
}

class BudgetCapEntity extends Equatable {
  final String id;
  final String budgetId;
  final String categoryId;
  final double plannedAmount;
  final double? dynamicAmount;
  final DateTime createdAt;

  const BudgetCapEntity({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.plannedAmount,
    this.dynamicAmount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        budgetId,
        categoryId,
        plannedAmount,
        dynamicAmount,
        createdAt,
      ];

  BudgetCapEntity copyWith({
    String? id,
    String? budgetId,
    String? categoryId,
    double? plannedAmount,
    double? dynamicAmount,
    DateTime? createdAt,
  }) {
    return BudgetCapEntity(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      dynamicAmount: dynamicAmount ?? this.dynamicAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Budget utilization data with spending metrics
class BudgetUtilization extends Equatable {
  final String budgetCapId;
  final String categoryId;
  final String categoryName;
  final double plannedAmount;
  final double? dynamicAmount;
  final double spentAmount;
  final double utilizationPercentage;

  const BudgetUtilization({
    required this.budgetCapId,
    required this.categoryId,
    required this.categoryName,
    required this.plannedAmount,
    this.dynamicAmount,
    required this.spentAmount,
    required this.utilizationPercentage,
  });

  /// Get budget status flag
  BudgetStatus get status {
    if (utilizationPercentage > 100) return BudgetStatus.exceeded;
    if (utilizationPercentage > 80) return BudgetStatus.warning;
    return BudgetStatus.good;
  }

  @override
  List<Object?> get props => [
        budgetCapId,
        categoryId,
        categoryName,
        plannedAmount,
        dynamicAmount,
        spentAmount,
        utilizationPercentage,
      ];
}

enum BudgetStatus { good, warning, exceeded }
