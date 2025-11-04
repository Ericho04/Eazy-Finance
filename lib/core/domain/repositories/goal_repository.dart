import '../../../core/errors/result.dart';
import '../entities/goal_entity.dart';

abstract class GoalRepository {
  /// Create a new goal
  Future<Result<GoalEntity>> createGoal(GoalEntity goal);

  /// Get all goals for a user
  Future<Result<List<GoalEntity>>> getGoals({GoalStatus? status});

  /// Get goal by ID with contributions
  Future<Result<GoalEntity>> getGoal(String id);

  /// Update goal
  Future<Result<GoalEntity>> updateGoal(GoalEntity goal);

  /// Delete goal
  Future<Result<void>> deleteGoal(String id);

  /// Add contribution to goal
  Future<Result<GoalContributionEntity>> addContribution(
    String goalId,
    GoalContributionEntity contribution,
  );

  /// Get contributions for a goal
  Future<Result<List<GoalContributionEntity>>> getContributions(String goalId);
}
