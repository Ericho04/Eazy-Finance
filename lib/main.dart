import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

//import providers
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

//import widgets
import 'widget/bottom_navigation.dart';

// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/dashboard_screen.dart';
//import 'screens/placeholder_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/expense_entry_screen.dart';
import 'screens/expense_history_screen.dart';
import 'screens/financial_accounts_screen.dart';
import 'screens/financial_debts_screen.dart';
import 'screens/financial_goals_screen.dart';
import 'screens/financial_screen.dart';
import 'screens/financial_tax_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/lucky_draw_screen.dart';
import 'screens/main_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/rewards_shop_screen.dart';
import 'screens/settings_screen.dart';




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
  // Map<String, dynamic>? scanData; // Removed scanData

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
          currentView = 'app';
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
      // Removed 'ocr-scan' and 'qr-scan' block
      if (['financial-debts', 'financial-tax'].contains(currentView)) {
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

  // Removed _handleScanComplete method

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
          prefilledData: null, // Set prefilledData to null
        );
      case 'expense-history':
        return ExpenseHistoryScreen(onBack: _handleBack);
      case 'reports':
        return ReportsScreen(onBack: _handleBack);
    // Removed 'ocr-scan' case
    // Removed 'qr-scan' case
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


