import 'package:flutter/material.dart';


import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/financial_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      label: 'Home',
      emoji: '🏠',
      gradient: [SFMSTheme.cartoonBlue, const Color(0xFF7BB3FF)],
    ),
    NavigationItem(
      icon: Icons.credit_card_rounded,
      label: 'Budget',
      emoji: '💳',
      gradient: [SFMSTheme.successColor, const Color(0xFF81C784)],
    ),
    NavigationItem(
      icon: Icons.pie_chart_rounded,
      label: 'Finance',
      emoji: '💰',
      gradient: [SFMSTheme.warningColor, const Color(0xFFFFB74D)],
    ),
    NavigationItem(
      icon: Icons.bar_chart_rounded,
      label: 'Stats',
      emoji: '📊',
      gradient: [SFMSTheme.cartoonPink, const Color(0xFFFF8CC8)],
    ),
    NavigationItem(
      icon: Icons.settings_rounded,
      label: 'Settings',
      emoji: '⚙️',
      gradient: [Colors.grey.shade400, Colors.grey.shade600],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  // Navigation callback that accepts String parameter (matching screen expectations)
  void _handleNavigation(String route) {
    // Map route names to indices
    int index;
    switch (route.toLowerCase()) {
      case 'home':
      case 'dashboard':
        index = 0;
        break;
      case 'budget':
        index = 1;
        break;
      case 'finance':
      case 'financial':
        index = 2;
        break;
      case 'stats':
      case 'insights':
        index = 3;
        break;
      case 'settings':
        index = 4;
        break;
      default:
        index = 0; // Default to home
    }
    _onTabTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDBEAFE),
              Color(0xFFFAF5FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            DashboardScreen(onNavigate: _handleNavigation),
            BudgetScreen(onNavigate: _handleNavigation),
            FinancialScreen(onNavigate: _handleNavigation),
            InsightsScreen(onNavigate: _handleNavigation),
            SettingsScreen(onNavigate: _handleNavigation,),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;

            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: isSelected
                    ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: item.gradient.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
                    : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isSelected)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animationController.value * 0.1,
                            child: Text(
                              item.emoji,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    Icon(
                      item.icon,
                      size: 24,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String emoji;
  final List<Color> gradient;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.emoji,
    required this.gradient,
  });
}