import '../../../core/errors/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign up with email and password
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    String? fullName,
  });

  /// Sign in with email and password
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<Result<void>> signOut();

  /// Get current authenticated user
  Future<Result<UserEntity?>> getCurrentUser();

  /// Send password reset email
  Future<Result<void>> resetPassword(String email);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}
