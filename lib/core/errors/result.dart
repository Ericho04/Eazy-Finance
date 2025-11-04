import 'package:dartz/dartz.dart';
import 'failures.dart';

/// Type alias for Result pattern
/// Returns Either<Failure, T> where:
/// - Left: Failure (error case)
/// - Right: T (success case)
typedef Result<T> = Either<Failure, T>;
