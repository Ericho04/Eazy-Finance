import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isAuthenticated = false;
  String _currentView = 'login';
  String _activeTab = 'dashboard';
  bool _isDarkMode = false;

  AuthProvider(this._prefs) {
    _loadAuthState();
    _loadThemeState();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String get currentView => _currentView;
  String get activeTab => _activeTab;
  bool get isDarkMode => _isDarkMode;

  void _loadAuthState() {
    _isAuthenticated = _prefs.getBool('sfms_demo_authenticated') ?? false;
    if (_isAuthenticated) {
      _currentView = 'dashboard';
      _activeTab = 'dashboard';
    }
    notifyListeners();
  }

  void _loadThemeState() {
    _isDarkMode = _prefs.getBool('sfms_dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    _isAuthenticated = true;
    _currentView = 'dashboard';
    _activeTab = 'dashboard';
    await _prefs.setBool('sfms_demo_authenticated', true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentView = 'login';
    _activeTab = 'dashboard';
    await _prefs.setBool('sfms_demo_authenticated', false);
    notifyListeners();
  }

  void setCurrentView(String view) {
    _currentView = view;
    notifyListeners();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('sfms_dark_mode', _isDarkMode);
    notifyListeners();
  }

  // Navigation helpers
  bool shouldShowBottomNav() {
    return ['dashboard', 'budget', 'financial', 'insights', 'settings']
        .contains(_currentView);
  }

  void navigateToFinancialSubPage(String subPage) {
    final financialSubPages = {
      'debts': 'financial-debts',
      'accounts': 'financial-accounts',
      'goals': 'financial-goals',
      'tax': 'financial-tax',
    };
    
    if (financialSubPages.containsKey(subPage)) {
      setCurrentView(financialSubPages[subPage]!);
    }
  }

  void navigateBack() {
    if (_isAuthenticated) {
      // Handle back navigation from financial sub-pages
      if (['financial-debts', 'financial-accounts', 'financial-goals', 'financial-tax']
          .contains(_currentView)) {
        setCurrentView('financial');
        setActiveTab('financial');
      } else {
        setCurrentView(_activeTab);
      }
    } else {
      setCurrentView('login');
    }
  }

  // Auth flow navigation
  void navigateToForgotPassword() => setCurrentView('forgot-password');
  void navigateToOTP() => setCurrentView('otp');
  void navigateToLogin() => setCurrentView('login');

  // Main app navigation
  void navigateToAddExpense() => setCurrentView('add-expense');
  void navigateToExpenseHistory() => setCurrentView('expense-history');
  void navigateToReports() => setCurrentView('reports');
}