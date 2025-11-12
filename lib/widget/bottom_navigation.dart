import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

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
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final navBgColor = isDarkMode ? SFMSTheme.darkCardBg : Colors.white;
    final selectedColor = isDarkMode ? SFMSTheme.darkAccentTeal : const Color(0xFF2E7D32);
    final unselectedColor = isDarkMode ? SFMSTheme.darkTextMuted : Colors.grey;
    final shadowColor = isDarkMode
        ? SFMSTheme.darkAccentTeal.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

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
        color: navBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
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
                      ? selectedColor.withOpacity(isDarkMode ? 0.2 : 0.1)
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