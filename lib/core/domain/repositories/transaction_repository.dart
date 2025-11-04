import '../../../core/errors/result.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Create a new transaction
  Future<Result<TransactionEntity>> createTransaction(TransactionEntity transaction);

  /// Get all transactions for a user
  Future<Result<List<TransactionEntity>>> getTransactions({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get transaction by ID
  Future<Result<TransactionEntity>> getTransaction(String id);

  /// Update transaction
  Future<Result<TransactionEntity>> updateTransaction(TransactionEntity transaction);

  /// Delete transaction
  Future<Result<void>> deleteTransaction(String id);

  /// Get transactions for a specific month
  Future<Result<List<TransactionEntity>>> getMonthlyTransactions(int year, int month);
}
