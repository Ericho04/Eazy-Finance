import '../../../core/errors/result.dart';
import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  /// Create a new budget
  Future<Result<BudgetEntity>> createBudget(BudgetEntity budget);

  /// Get budget for a specific month
  Future<Result<BudgetEntity?>> getBudget(int year, int month);

  /// Update budget
  Future<Result<BudgetEntity>> updateBudget(BudgetEntity budget);

  /// Delete budget
  Future<Result<void>> deleteBudget(String id);

  /// Get budget utilization for a specific month
  Future<Result<List<BudgetUtilization>>> getBudgetUtilization(int year, int month);

  /// Add or update budget cap
  Future<Result<BudgetCapEntity>> upsertBudgetCap(BudgetCapEntity cap);

  /// Delete budget cap
  Future<Result<void>> deleteBudgetCap(String id);
}
