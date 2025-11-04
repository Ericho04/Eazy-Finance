import 'package:equatable/equatable.dart';

class RewardEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool active;
  final DateTime createdAt;

  const RewardEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.active,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, description, active, createdAt];

  RewardEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? active,
    DateTime? createdAt,
  }) {
    return RewardEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LuckyDrawEntryEntity extends Equatable {
  final String id;
  final String userId;
  final String? goalId;
  final DateTime awardedAt;
  final String? outcome;

  const LuckyDrawEntryEntity({
    required this.id,
    required this.userId,
    this.goalId,
    required this.awardedAt,
    this.outcome,
  });

  /// Check if entry has been drawn
  bool get isDrawn => outcome != null;

  /// Check if entry won a reward
  bool get isWinner => outcome != null && outcome != 'no_win';

  @override
  List<Object?> get props => [id, userId, goalId, awardedAt, outcome];

  LuckyDrawEntryEntity copyWith({
    String? id,
    String? userId,
    String? goalId,
    DateTime? awardedAt,
    String? outcome,
  }) {
    return LuckyDrawEntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      awardedAt: awardedAt ?? this.awardedAt,
      outcome: outcome ?? this.outcome,
    );
  }
}
