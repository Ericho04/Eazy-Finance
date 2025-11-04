import 'package:equatable/equatable.dart';

class TaxProfileEntity extends Equatable {
  final String id;
  final String userId;
  final int assessmentYear;
  final DateTime createdAt;
  final List<TaxClaimEntity> claims;

  const TaxProfileEntity({
    required this.id,
    required this.userId,
    required this.assessmentYear,
    required this.createdAt,
    this.claims = const [],
  });

  /// Calculate total claimed amount
  double get totalClaimed {
    return claims.fold(0.0, (sum, c) => sum + c.amount);
  }

  @override
  List<Object?> get props => [id, userId, assessmentYear, createdAt, claims];

  TaxProfileEntity copyWith({
    String? id,
    String? userId,
    int? assessmentYear,
    DateTime? createdAt,
    List<TaxClaimEntity>? claims,
  }) {
    return TaxProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      createdAt: createdAt ?? this.createdAt,
      claims: claims ?? this.claims,
    );
  }
}

class TaxReliefCategoryEntity extends Equatable {
  final String id;
  final String code;
  final String label;
  final double annualLimit;

  const TaxReliefCategoryEntity({
    required this.id,
    required this.code,
    required this.label,
    required this.annualLimit,
  });

  @override
  List<Object?> get props => [id, code, label, annualLimit];

  TaxReliefCategoryEntity copyWith({
    String? id,
    String? code,
    String? label,
    double? annualLimit,
  }) {
    return TaxReliefCategoryEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      annualLimit: annualLimit ?? this.annualLimit,
    );
  }
}

class TaxClaimEntity extends Equatable {
  final String id;
  final String taxProfileId;
  final String categoryId;
  final double amount;
  final DateTime claimedOn;
  final String? note;

  const TaxClaimEntity({
    required this.id,
    required this.taxProfileId,
    required this.categoryId,
    required this.amount,
    required this.claimedOn,
    this.note,
  });

  @override
  List<Object?> get props => [id, taxProfileId, categoryId, amount, claimedOn, note];

  TaxClaimEntity copyWith({
    String? id,
    String? taxProfileId,
    String? categoryId,
    double? amount,
    DateTime? claimedOn,
    String? note,
  }) {
    return TaxClaimEntity(
      id: id ?? this.id,
      taxProfileId: taxProfileId ?? this.taxProfileId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      claimedOn: claimedOn ?? this.claimedOn,
      note: note ?? this.note,
    );
  }
}

/// Tax relief utilization summary
class TaxReliefUtilization extends Equatable {
  final TaxReliefCategoryEntity category;
  final double claimedAmount;
  final double remainingQuota;
  final double estimatedSavings;

  const TaxReliefUtilization({
    required this.category,
    required this.claimedAmount,
    required this.remainingQuota,
    required this.estimatedSavings,
  });

  /// Check if limit is reached
  bool get isLimitReached => remainingQuota <= 0;

  /// Get utilization percentage
  double get utilizationPercentage {
    if (category.annualLimit == 0) return 0.0;
    return ((claimedAmount / category.annualLimit) * 100).clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
        category,
        claimedAmount,
        remainingQuota,
        estimatedSavings,
      ];
}
