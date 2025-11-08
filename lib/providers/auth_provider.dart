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

  // ✅ 修复：添加 emailRedirectTo 参数，确保邮件验证后跳转到 App
  Future<bool> signUp(String email, String password, String fullName) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
        // 🔑 关键修改：指定 Flutter App 的 deep link
        emailRedirectTo: 'com.sfms.app://auth-callback',
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

  // ✅ 添加：重置密码功能（如果需要）
  Future<bool> resetPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.sfms.app://auth-callback',
      );
      return true;
    } catch (e) {
      print('Reset password error: $e');
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
}