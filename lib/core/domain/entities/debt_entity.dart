import 'package:equatable/equatable.dart';

class DebtEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double principal;
  final double apr;
  final int termMonths;
  final int? dueDay;
  final DateTime startDate;
  final double extraMonthlyPayment;
  final DateTime createdAt;
  final List<DebtPaymentEntity> payments;

  const DebtEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.principal,
    required this.apr,
    required this.termMonths,
    this.dueDay,
    required this.startDate,
    this.extraMonthlyPayment = 0,
    required this.createdAt,
    this.payments = const [],
  });

  /// Calculate monthly payment amount (without extra payment)
  double get monthlyPayment {
    if (apr == 0) {
      return principal / termMonths;
    }
    final monthlyRate = apr / 12 / 100;
    return principal *
        (monthlyRate * pow(1 + monthlyRate, termMonths)) /
        (pow(1 + monthlyRate, termMonths) - 1);
  }

  /// Calculate total payment (base + extra)
  double get totalMonthlyPayment {
    return monthlyPayment + extraMonthlyPayment;
  }

  /// Calculate total paid so far
  double get totalPaid {
    return payments.fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Calculate remaining balance
  double get remainingBalance {
    return (principal - totalPaid).clamp(0.0, double.infinity);
  }

  /// Calculate total interest to be paid over the life of the loan
  double get totalInterest {
    return (monthlyPayment * termMonths) - principal;
  }

  /// Calculate payoff date based on payments
  DateTime get estimatedPayoffDate {
    if (totalMonthlyPayment == 0) {
      return startDate.add(Duration(days: termMonths * 30));
    }

    // Simplified calculation - actual implementation would use amortization
    final monthsToPayoff = (remainingBalance / totalMonthlyPayment).ceil();
    return DateTime.now().add(Duration(days: monthsToPayoff * 30));
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        principal,
        apr,
        termMonths,
        dueDay,
        startDate,
        extraMonthlyPayment,
        createdAt,
        payments,
      ];

  DebtEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? principal,
    double? apr,
    int? termMonths,
    int? dueDay,
    DateTime? startDate,
    double? extraMonthlyPayment,
    DateTime? createdAt,
    List<DebtPaymentEntity>? payments,
  }) {
    return DebtEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      principal: principal ?? this.principal,
      apr: apr ?? this.apr,
      termMonths: termMonths ?? this.termMonths,
      dueDay: dueDay ?? this.dueDay,
      startDate: startDate ?? this.startDate,
      extraMonthlyPayment: extraMonthlyPayment ?? this.extraMonthlyPayment,
      createdAt: createdAt ?? this.createdAt,
      payments: payments ?? this.payments,
    );
  }
}

class DebtPaymentEntity extends Equatable {
  final String id;
  final String debtId;
  final double amount;
  final DateTime paidOn;
  final String? note;

  const DebtPaymentEntity({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paidOn,
    this.note,
  });

  @override
  List<Object?> get props => [id, debtId, amount, paidOn, note];

  DebtPaymentEntity copyWith({
    String? id,
    String? debtId,
    double? amount,
    DateTime? paidOn,
    String? note,
  }) {
    return DebtPaymentEntity(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      paidOn: paidOn ?? this.paidOn,
      note: note ?? this.note,
    );
  }
}

/// Amortization schedule entry
class AmortizationEntry extends Equatable {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const AmortizationEntry({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  @override
  List<Object?> get props => [month, payment, principal, interest, balance];
}

/// DTI (Debt-to-Income) analysis
class DTIAnalysis extends Equatable {
  final double monthlyIncome;
  final double totalMonthlyDebtPayments;
  final double dtiRatio;

  const DTIAnalysis({
    required this.monthlyIncome,
    required this.totalMonthlyDebtPayments,
    required this.dtiRatio,
  });

  /// Get DTI label based on ratio
  DTILabel get label {
    if (dtiRatio < 0.36) return DTILabel.safe;
    if (dtiRatio < 0.43) return DTILabel.borderline;
    return DTILabel.risky;
  }

  @override
  List<Object?> get props => [monthlyIncome, totalMonthlyDebtPayments, dtiRatio];
}

enum DTILabel { safe, borderline, risky }

// Helper function for power calculation
double pow(double base, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
