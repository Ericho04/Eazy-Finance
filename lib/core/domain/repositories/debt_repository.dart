import '../../../core/errors/result.dart';
import '../entities/debt_entity.dart';

abstract class DebtRepository {
  /// Create a new debt
  Future<Result<DebtEntity>> createDebt(DebtEntity debt);

  /// Get all debts for a user
  Future<Result<List<DebtEntity>>> getDebts();

  /// Get debt by ID with payments
  Future<Result<DebtEntity>> getDebt(String id);

  /// Update debt
  Future<Result<DebtEntity>> updateDebt(DebtEntity debt);

  /// Delete debt
  Future<Result<void>> deleteDebt(String id);

  /// Add payment to debt
  Future<Result<DebtPaymentEntity>> addPayment(
    String debtId,
    DebtPaymentEntity payment,
  );

  /// Get payments for a debt
  Future<Result<List<DebtPaymentEntity>>> getPayments(String debtId);

  /// Calculate amortization schedule
  List<AmortizationEntry> calculateAmortization(DebtEntity debt);

  /// Calculate DTI ratio
  Future<Result<DTIAnalysis>> calculateDTI(double monthlyIncome);
}
