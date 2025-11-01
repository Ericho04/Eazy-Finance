import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math';

// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/dashboard_screen.dart';
// import 'screens/admin_app.dart'; // Admin panel is separate web app
import 'screens/placeholder_screen.dart';

// Main App Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ugrcqjjovugagaknjwoa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVncmNxampvdnVnYWdha25qd29hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MTk4NzEsImV4cCI6MjA3MDM5NTg3MX0.wsCAS216K86Y6RCR9PL5rJ57WQDFzfDFOR_4f7ePSe8',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SFMSApp(),
    ),
  );
}

// SFMS App Root
class SFMSApp extends StatelessWidget {
  const SFMSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SFMS - Smart Finance Management System',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AppContent(),
        );
      },
    );
  }
}

// App Content with Navigation Logic
class AppContent extends StatefulWidget {
  const AppContent({Key? key}) : super(key: key);

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> with TickerProviderStateMixin {
  String activeTab = 'dashboard';
  String currentView = 'login';
  // Admin panel is separate web app - not included in mobile
  bool loading = true;
  bool showConfigNotice = false;
  Map<String, dynamic>? scanData;

  late AnimationController _backgroundController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        context.read<AuthProvider>().setUser(user);
        setState(() {
          currentView = 'dashboard';
          activeTab = 'dashboard';
        });
      } else {
        setState(() {
          currentView = 'login';
        });
      }
    } catch (e) {
      print('Auth check error: $e');
      setState(() {
        currentView = 'login';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _handleNavigation(String destination) {
    setState(() {
      currentView = destination;

      // Update active tab if navigating to a main section
      const mainTabs = [
        'dashboard',
        'budget',
        'financial',
        'goals',
        'insights'
      ];
      if (mainTabs.contains(destination)) {
        activeTab = destination;
      }
    });
  }

  void _handleBack() {
    if (context.read<AuthProvider>().user != null) {
      // Handle back navigation logic
      if (['ocr-scan', 'qr-scan'].contains(currentView)) {
        setState(() {
          currentView = 'add-expense';
          scanData = null;
        });
      } else if (['financial-debts', 'financial-tax'].contains(currentView)) {
        setState(() {
          currentView = 'financial';
          activeTab = 'financial';
        });
      } else if (['lucky-draw', 'rewards-shop'].contains(currentView)) {
        setState(() {
          currentView = 'goals';
          activeTab = 'goals';
        });
      } else if (currentView == 'settings') {
        setState(() {
          currentView = activeTab;
        });
      } else {
        setState(() {
          currentView = activeTab;
        });
      }
    } else {
      setState(() {
        currentView = 'login';
      });
    }
  }

  void _handleScanComplete(Map<String, dynamic> data) {
    setState(() {
      scanData = data;
      currentView = 'add-expense';
    });
  }

  // Admin login removed - use web admin panel at /admin

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFDBEAFE),
              Color(0xFFFAF5FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _backgroundController,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E8EF7), Color(0xFF845EC2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading SFMS...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthView() {
    switch (currentView) {
      case 'login':
        return LoginScreen(
          onNavigate: _handleNavigation,
        );
      case 'signup':
        return SignupScreen(onNavigate: _handleNavigation);
      case 'forgot-password':
        return ForgotPasswordScreen(onNavigate: _handleNavigation);
      case 'otp':
        return OTPScreen(onNavigate: _handleNavigation);
      default:
        return LoginScreen(
          onNavigate: _handleNavigation,
        );
    }
  }

  Widget _buildMainView() {
    switch (currentView) {
      case 'dashboard':
        return DashboardScreen(onNavigate: _handleNavigation);
      case 'budget':
        return BudgetScreen(onNavigate: _handleNavigation);
      case 'financial':
        return FinancialScreen(onNavigate: _handleNavigation);
      case 'financial-debts':
        return FinancialDebtsScreen(onBack: _handleBack);
      case 'financial-tax':
        return FinancialTaxScreen(onBack: _handleBack);
      case 'goals':
        return GoalsScreen(onNavigate: _handleNavigation);
      case 'lucky-draw':
        return LuckyDrawScreen(onBack: _handleBack);
      case 'rewards-shop':
        return RewardsShopScreen(onBack: _handleBack);
      case 'insights':
        return InsightsScreen(onNavigate: _handleNavigation);
      case 'settings':
        return SettingsScreen(onNavigate: _handleNavigation);
      case 'add-expense':
        return ExpenseEntryScreen(
          onBack: _handleBack,
          onNavigate: _handleNavigation,
          prefilledData: scanData,
        );
      case 'expense-history':
        return ExpenseHistoryScreen(onBack: _handleBack);
      case 'reports':
        return ReportsScreen(onBack: _handleBack);
      case 'ocr-scan':
        return OCRScannerScreen(
          onBack: _handleBack,
          onScanComplete: _handleScanComplete,
        );
      case 'qr-scan':
        return QRScannerScreen(
          onBack: _handleBack,
          onScanComplete: _handleScanComplete,
        );
      default:
        return DashboardScreen(onNavigate: _handleNavigation);
    }
  }

  bool _shouldShowBottomNav() {
    return ['dashboard', 'budget', 'financial', 'goals', 'insights']
        .contains(currentView);
  }

  bool _shouldShowSettings() {
    return _shouldShowBottomNav();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingScreen();
    }

    // If not authenticated, show auth pages
    if (context.watch<AuthProvider>().user == null) {
      return _buildAuthView();
    }

    // Main authenticated app
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFFDBEAFE),
                        const Color(0xFFEDE9FE),
                        (_backgroundController.value * 2) % 1,
                      )!,
                      Color.lerp(
                        const Color(0xFFFAF5FF),
                        const Color(0xFFFEF3C7),
                        (_backgroundController.value * 2) % 1,
                      )!,
                      Color.lerp(
                        const Color(0xFFFDF2F8),
                        const Color(0xFFFED7D7),
                        (_backgroundController.value * 2) % 1,
                      )!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Floating elements
                    ...List.generate(8, (i) {
                      return Positioned(
                        left: (10 + i * 12) *
                            MediaQuery.of(context).size.width /
                            100,
                        top: (15 + (i % 3) * 25) *
                            MediaQuery.of(context).size.height /
                            100,
                        child: AnimatedBuilder(
                          animation: _backgroundController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                -20 *
                                    sin((_backgroundController.value * 2 * pi) +
                                        (i * 0.5)),
                              ),
                              child: Transform.rotate(
                                angle: _backgroundController.value * 2 * pi +
                                    (i * 0.5),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF8B5CF6)
                                            .withOpacity(0.1),
                                        const Color(0xFFEC4899)
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    // Floating emojis
                    ...['💰', '🎯', '📊', '💳', '🏦', '🎁', '⭐']
                        .asMap()
                        .entries
                        .map((entry) {
                      int i = entry.key;
                      String emoji = entry.value;
                      return Positioned(
                        left: (15 + i * 12) *
                            MediaQuery.of(context).size.width /
                            100,
                        top: (10 + i * 12) *
                            MediaQuery.of(context).size.height /
                            100,
                        child: AnimatedBuilder(
                          animation: _backgroundController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                10 *
                                    sin((_backgroundController.value * 2 * pi) +
                                        (i * 1.2)),
                                -30 *
                                    sin((_backgroundController.value * 2 * pi) +
                                        (i * 1.2)),
                              ),
                              child: Transform.rotate(
                                angle: 0.1 *
                                    sin((_backgroundController.value * 2 * pi) +
                                        (i * 1.2)),
                                child: Opacity(
                                  opacity: 0.2,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Settings button
                if (_shouldShowSettings())
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton.small(
                        onPressed: () =>
                            setState(() => currentView = 'settings'),
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child:
                            const Icon(Icons.settings, color: Colors.black87),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),

                // Main content area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticOut,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(currentView),
                      child: _buildMainView(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: _shouldShowBottomNav()
          ? BottomNavigation(
              activeTab: activeTab,
              onTabChange: (tab) {
                setState(() {
                  activeTab = tab;
                  currentView = tab;
                });
              },
            )
          : null,
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
}

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2E7D32),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF4CAF50),
        surface: Color(0xFFFFFFFF),
        background: Color(0xFFF8FAFF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        onBackground: Color(0xFF1A1A1A),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadowColor: Colors.black.withOpacity(0.12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 6,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF4CAF50),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50),
        secondary: Color(0xFF81C784),
        surface: Color(0xFF1C2128),
        background: Color(0xFF0F1419),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Color(0xFFE6EDF3),
        onBackground: Color(0xFFE6EDF3),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: const Color(0xFF1C2128),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 6,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
    );
  }
}

// Auth Provider
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
        setUser(response.user!);
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
    // Create a mock user for demo purposes
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

// App Provider for global state
class AppProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<Goal> _goals = [];

  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<Goal> get goals => _goals;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void addBudget(Budget budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  // Demo data initialization
  void initializeDemoData() {
    _transactions = [
      Transaction(
        id: '1',
        amount: 25.50,
        description: 'Coffee & Pastry',
        category: 'Food & Dining',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'expense',
      ),
      Transaction(
        id: '2',
        amount: 1200.00,
        description: 'Salary Deposit',
        category: 'Income',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'income',
      ),
      Transaction(
        id: '3',
        amount: 85.00,
        description: 'Grocery Shopping',
        category: 'Groceries',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'expense',
      ),
    ];

    _budgets = [
      Budget(
        id: '1',
        name: 'Food & Dining',
        amount: 500.0,
        spent: 125.50,
        color: const Color(0xFF4CAF50),
        icon: '🍽️',
      ),
      Budget(
        id: '2',
        name: 'Transportation',
        amount: 200.0,
        spent: 45.0,
        color: const Color(0xFF2196F3),
        icon: '🚗',
      ),
    ];

    _goals = [
      Goal(
        id: '1',
        name: 'Emergency Fund',
        targetAmount: 5000.0,
        currentAmount: 2750.0,
        targetDate: DateTime.now().add(const Duration(days: 180)),
        color: const Color(0xFF4CAF50),
        icon: '🏦',
      ),
      Goal(
        id: '2',
        name: 'Vacation Trip',
        targetAmount: 2000.0,
        currentAmount: 850.0,
        targetDate: DateTime.now().add(const Duration(days: 90)),
        color: const Color(0xFFFF9800),
        icon: '✈️',
      ),
    ];

    notifyListeners();
  }
}

// Models
class Transaction {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String type; // 'income' or 'expense'

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }
}

class Budget {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final Color color;
  final String icon;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.spent,
    required this.color,
    required this.icon,
  });

  double get remaining => amount - spent;
  double get percentage => (spent / amount).clamp(0.0, 1.0);
}

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final Color color;
  final String icon;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.color,
    required this.icon,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => targetAmount - currentAmount;

  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }
}

// Bottom Navigation Widget
class BottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const BottomNavigation({
    Key? key,
    required this.activeTab,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'dashboard', 'label': 'Home', 'icon': Icons.home_rounded},
      {'id': 'budget', 'label': 'Budget', 'icon': Icons.pie_chart_rounded},
      {
        'id': 'financial',
        'label': 'Finance',
        'icon': Icons.account_balance_rounded
      },
      {'id': 'goals', 'label': 'Goals', 'icon': Icons.flag_rounded},
      {'id': 'insights', 'label': 'Insights', 'icon': Icons.analytics_rounded},
    ];

    return Container(
      height: 100 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BottomNavigationBar(
          currentIndex: tabs.indexWhere((tab) => tab['id'] == activeTab),
          onTap: (index) => onTabChange(tabs[index]['id'] as String),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: activeTab == tab['id']
                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  tab['icon'] as IconData,
                  size: activeTab == tab['id'] ? 28 : 24,
                ),
              ),
              label: tab['label'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }
}
