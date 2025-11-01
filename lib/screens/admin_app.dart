import 'package:flutter/material.dart';
import 'dart:math';

class AdminApp extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminApp({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> with TickerProviderStateMixin {
  String currentView = 'dashboard';
  Map<String, int> adminStats = {
    'totalPrizes': 7,
    'totalShopItems': 8,
    'totalUsers': 1247,
    'totalTransactions': 3892,
  };

  late AnimationController _backgroundController;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStatsUpdates();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  void _startStatsUpdates() {
    // Simulate real-time stats updates
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          adminStats['totalUsers'] =
              adminStats['totalUsers']! + (Random().nextInt(3));
          adminStats['totalTransactions'] =
              adminStats['totalTransactions']! + (Random().nextInt(5));
        });
        _startStatsUpdates(); // Continue updating
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1), // Amber 50
              Color(0xFFFFF3E0), // Orange 50
              Color(0xFFFFF59D), // Yellow 100
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating Background Elements
            ...List.generate(5, (i) {
              return Positioned(
                left: (10 + i * 20) * MediaQuery.of(context).size.width / 100,
                top: (20 + i * 15) * MediaQuery.of(context).size.height / 100,
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -30 *
                            sin((_backgroundController.value * 2 * pi) +
                                (i * 2)),
                      ),
                      child: Transform.rotate(
                        angle: _backgroundController.value * 2 * pi + (i * 2),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade300.withOpacity(0.05),
                                Colors.orange.shade300.withOpacity(0.05),
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

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Admin Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Navigation Buttons
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildNavButton(
                                    'Dashboard', 'dashboard', Icons.dashboard),
                                const SizedBox(width: 8),
                                _buildNavButton(
                                    'Prizes', 'prizes', Icons.casino),
                                const SizedBox(width: 8),
                                _buildNavButton(
                                    'Shop', 'shop', Icons.shopping_cart),
                                const SizedBox(width: 8),
                                _buildNavButton(
                                    'Analytics', 'analytics', Icons.analytics),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Admin Info & Logout
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield,
                                size: 16,
                                color: Colors.amber.shade800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        IconButton(
                          onPressed: widget.onLogout,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.logout,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content Area
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(currentView),
                        child: _buildCurrentView(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, String view, IconData icon) {
    final isActive = currentView == view;
    return GestureDetector(
      onTap: () => setState(() => currentView = view),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber.shade500 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'dashboard':
        return _buildDashboard();
      case 'prizes':
        return _buildPrizesManagement();
      case 'shop':
        return _buildShopManagement();
      case 'analytics':
        return _buildAnalytics();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          FadeTransition(
            opacity: _cardController,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _backgroundController.value * 2 * pi,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade500,
                              Colors.orange.shade500
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'SFMS Admin Panel',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your rewards and gamification system',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    'Administrator Access',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stats Overview
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                '🎰',
                adminStats['totalPrizes']!.toString(),
                'Lucky Draw Prizes',
                Colors.purple.shade500,
                0.1,
              ),
              _buildStatCard(
                '🛒',
                adminStats['totalShopItems']!.toString(),
                'Shop Items',
                Colors.pink.shade500,
                0.2,
              ),
              _buildStatCard(
                '👥',
                adminStats['totalUsers']!.toString(),
                'Active Users',
                Colors.blue.shade500,
                0.3,
              ),
              _buildStatCard(
                '💰',
                adminStats['totalTransactions']!.toString(),
                'Total Transactions',
                Colors.green.shade500,
                0.4,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: [
              _buildQuickActionCard(
                '🎰',
                'Lucky Draw Management',
                'Configure prizes, probabilities, and spin mechanics',
                Colors.purple.shade500,
                () => setState(() => currentView = 'prizes'),
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                '🛒',
                'Rewards Shop',
                'Add items, set prices, and manage inventory',
                Colors.pink.shade500,
                () => setState(() => currentView = 'shop'),
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                '📊',
                'Analytics & Reports',
                'View detailed statistics and user engagement',
                Colors.blue.shade500,
                () => setState(() => currentView = 'analytics'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildActivityItem(
                    '✏️',
                    'Prize Updated',
                    'Grab Food Voucher',
                    '2 minutes ago',
                    Colors.blue.shade500,
                  ),
                  _buildActivityItem(
                    '👤',
                    'New User Registered',
                    'user@example.com',
                    '5 minutes ago',
                    Colors.green.shade500,
                  ),
                  _buildActivityItem(
                    '🛒',
                    'Shop Item Purchased',
                    'Starbucks Voucher',
                    '8 minutes ago',
                    Colors.purple.shade500,
                  ),
                  _buildActivityItem(
                    '🎰',
                    'Lucky Draw Spin',
                    'Bonus Points won',
                    '12 minutes ago',
                    Colors.orange.shade500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String emoji, String value, String label, Color color, double delay) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: (600 + (delay * 1000)).toInt()),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double scaleValue, child) {
        return Transform.scale(
          scale: scaleValue,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    String emoji,
    String title,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String emoji,
    String action,
    String item,
    String time,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizesManagement() {
    return const Center(
      child: Text(
        'Lucky Draw Prize Management\n(Under Development)',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildShopManagement() {
    return const Center(
      child: Text(
        'Rewards Shop Management\n(Under Development)',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnalytics() {
    return const Center(
      child: Text(
        'Analytics & Reports\n(Under Development)',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    super.dispose();
  }
}
