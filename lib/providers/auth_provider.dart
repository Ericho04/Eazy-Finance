import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        setUser(response.user!);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      clearUser();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<bool> demoLogin() async {
    final mockUser = User(
      id: 'demo-user-id',
      appMetadata: {},
      userMetadata: {
        'full_name': 'Demo User',
        'email': 'demo@sfms.app',
      },
      aud: 'demo',
      createdAt: DateTime.now().toIso8601String(),
    );

    setUser(mockUser);
    return true;
  }
}