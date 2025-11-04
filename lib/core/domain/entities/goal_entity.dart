import 'package:equatable/equatable.dart';

enum GoalStatus { active, completed, archived }

class GoalEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final DateTime? deadline;
  final GoalStatus status;
  final DateTime createdAt;
  final List<GoalContributionEntity> contributions;

  const GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.deadline,
    required this.status,
    required this.createdAt,
    this.contributions = const [],
  });

  /// Calculate total contributed amount
  double get contributedAmount {
    return contributions.fold(0.0, (sum, c) => sum + c.amount);
  }

  /// Calculate remaining amount to reach goal
  double get remainingAmount {
    return (targetAmount - contributedAmount).clamp(0.0, double.infinity);
  }

  /// Calculate progress percentage
  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return ((contributedAmount / targetAmount) * 100).clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        targetAmount,
        deadline,
        status,
        createdAt,
        contributions,
      ];

  GoalEntity copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    DateTime? deadline,
    GoalStatus? status,
    DateTime? createdAt,
    List<GoalContributionEntity>? contributions,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      contributions: contributions ?? this.contributions,
    );
  }
}

class GoalContributionEntity extends Equatable {
  final String id;
  final String goalId;
  final double amount;
  final DateTime contributedOn;
  final String? note;

  const GoalContributionEntity({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.contributedOn,
    this.note,
  });

  @override
  List<Object?> get props => [id, goalId, amount, contributedOn, note];

  GoalContributionEntity copyWith({
    String? id,
    String? goalId,
    double? amount,
    DateTime? contributedOn,
    String? note,
  }) {
    return GoalContributionEntity(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      contributedOn: contributedOn ?? this.contributedOn,
      note: note ?? this.note,
    );
  }
}
