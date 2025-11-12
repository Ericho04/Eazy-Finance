import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class RewardsShopScreen extends StatefulWidget {
  final VoidCallback onBack;

  const RewardsShopScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;

  String _activeCategory = 'vouchers';
  List<String> _purchasedItems = [];
  bool _showPurchaseModal = false;
  ShopItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animationController.forward();
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _handlePurchase(ShopItem item) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.rewardPoints >= item.pointsCost) {
      setState(() {
        _selectedItem = item;
        _showPurchaseModal = true;
      });
    }
  }

  void _confirmPurchase() {
    if (_selectedItem != null) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.spendRewardPoints(_selectedItem!.pointsCost);

      setState(() {
        _purchasedItems.add(_selectedItem!.id);
        _showPurchaseModal = false;
        _selectedItem = null;
      });

      // Update availability
      final itemIndex = _shopItems.indexWhere((item) => item.id == _selectedItem!.id);
      if (itemIndex != -1) {
        _shopItems[itemIndex] = _shopItems[itemIndex].copyWith(
          availability: _shopItems[itemIndex].availability - 1,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item redeemed successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<ShopItem> get _filteredItems {
    return _shopItems.where((item) => item.category == _activeCategory).toList();
  }

  int _getDiscountedPrice(int pointsCost, int discount) {
    return (pointsCost * (1 - discount / 100)).floor();
  }

  @override
  Widget build(BuildContext context) {
    // Dark Mode Support
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Theme-aware colors
    final bgColor = isDarkMode ? SFMSTheme.darkBgPrimary : SFMSTheme.backgroundColor;
    final textPrimary = isDarkMode ? SFMSTheme.darkTextPrimary : SFMSTheme.textPrimary;
    final textSecondary = isDarkMode ? SFMSTheme.darkTextSecondary : SFMSTheme.textSecondary;
    final textMuted = isDarkMode ? SFMSTheme.darkTextMuted : SFMSTheme.textMuted;
    final cardColor = isDarkMode ? SFMSTheme.darkBgSecondary : SFMSTheme.cardColor;
    final cardShadow = isDarkMode ? SFMSTheme.darkCardGlow : SFMSTheme.softCardShadow;

    // Background gradient colors
    final gradientColors = isDarkMode
        ? [
            SFMSTheme.darkBgPrimary,
            SFMSTheme.darkBgSecondary.withOpacity(0.5),
            SFMSTheme.darkBgPrimary,
          ]
        : [
            const Color(0xFFDBEAFE),
            const Color(0xFFFAF5FF),
            const Color(0xFFFDF2F8),
          ];

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardColor.withOpacity(0.8),
                            foregroundColor: textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        Consumer<AppProvider>(
                          builder: (context, appProvider, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    SFMSTheme.cartoonYellow,
                                    SFMSTheme.cartoonOrange,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: SFMSTheme.cartoonYellow.withOpacity(isDarkMode ? 0.5 : 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${appProvider.rewardPoints}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'points',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Title
                  AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + math.sin(_floatingController.value * 2 * math.pi) * 0.05,
                        child: Column(
                          children: [
                            const Text('🛒', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              'Rewards Shop',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Exchange your points for amazing rewards!',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Category Tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: cardShadow,
                    ),
                    child: Row(
                      children: _categories.map((category) {
                        final isActive = _activeCategory == category['id'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeCategory = category['id'] as String;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isActive
                                    ? LinearGradient(
                                  colors: [
                                    SFMSTheme.cartoonPurple,
                                    SFMSTheme.cartoonPink,
                                  ],
                                )
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    category['emoji'] as String,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['label'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white
                                          : (isDarkMode ? textSecondary : Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Shop Items
                  Expanded(
                    child: Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isPurchased = _purchasedItems.contains(item.id);
                            final canAfford = appProvider.rewardPoints >= item.pointsCost;

                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, (50 + index * 20) * (1 - _animationController.value)),
                                  child: Opacity(
                                    opacity: _animationController.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: cardShadow,
                                      ),
                                      child: Stack(
                                        children: [
                                          // Badges
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (item.isPopular)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? Colors.orange.withOpacity(0.2)
                                                          : Colors.orange.shade100,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '🔥 Popular',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDarkMode
                                                            ? Colors.orange.shade300
                                                            : Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                                if (item.isLimited)
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 4),
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? Colors.red.withOpacity(0.2)
                                                          : Colors.red.shade100,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '⚡ Limited',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDarkMode
                                                            ? Colors.red.shade300
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Purchased overlay
                                          if (isPurchased)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Center(
                                                child: CircleAvatar(
                                                  backgroundColor: isDarkMode
                                                      ? Colors.green.shade700
                                                      : Colors.green,
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),

                                          // Content
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 24), // Space for badges

                                                // Item emoji
                                                Center(
                                                  child: Text(
                                                    item.emoji,
                                                    style: const TextStyle(fontSize: 40),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),

                                                // Item details
                                                Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.description,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item.originalValue,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDarkMode
                                                        ? SFMSTheme.darkAccentTeal
                                                        : SFMSTheme.cartoonPurple,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),

                                                // Points and availability
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: isDarkMode
                                                              ? Colors.amber.shade300
                                                              : Colors.amber,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${item.pointsCost}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: textPrimary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '${item.availability} left',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),

                                                // Action button
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 36,
                                                  child: ElevatedButton(
                                                    onPressed: isPurchased || !canAfford || item.availability == 0
                                                        ? null
                                                        : () => _handlePurchase(item),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isPurchased
                                                          ? (isDarkMode ? Colors.green.shade700 : Colors.green)
                                                          : canAfford && item.availability > 0
                                                          ? SFMSTheme.cartoonPurple
                                                          : (isDarkMode
                                                              ? SFMSTheme.darkBgTertiary
                                                              : Colors.grey.shade300),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      isPurchased
                                                          ? 'Purchased'
                                                          : item.availability == 0
                                                          ? 'Sold Out'
                                                          : !canAfford
                                                          ? 'Not Enough'
                                                          : 'Redeem',
                                                      style: TextStyle(
                                                        color: isPurchased || (canAfford && item.availability > 0)
                                                            ? Colors.white
                                                            : (isDarkMode ? textMuted : Colors.grey.shade600),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Purchase confirmation modal overlay
          if (_showPurchaseModal && _selectedItem != null)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDarkMode
                        ? [
                            BoxShadow(
                              color: SFMSTheme.darkAccentTeal.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedItem!.emoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Confirm Purchase',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Are you sure you want to redeem this item?',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _selectedItem!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        _selectedItem!.originalValue,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? SFMSTheme.darkAccentTeal
                              : SFMSTheme.cartoonPurple,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? SFMSTheme.darkBgTertiary.withOpacity(0.3)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Consumer<AppProvider>(
                          builder: (context, appProvider, child) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: isDarkMode
                                          ? Colors.amber.shade300
                                          : Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedItem!.pointsCost} points',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Remaining balance: ${appProvider.rewardPoints - _selectedItem!.pointsCost} points',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showPurchaseModal = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? SFMSTheme.darkBgTertiary
                                    : Colors.grey.shade300,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDarkMode ? textPrimary : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _confirmPurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? SFMSTheme.darkAccentTeal
                                    : SFMSTheme.cartoonPurple,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Shop Item Model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final int pointsCost;
  final String originalValue;
  final int discount;
  final String emoji;
  final int availability;
  final bool isPopular;
  final bool isLimited;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pointsCost,
    required this.originalValue,
    required this.discount,
    required this.emoji,
    required this.availability,
    this.isPopular = false,
    this.isLimited = false,
  });

  ShopItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? pointsCost,
    String? originalValue,
    int? discount,
    String? emoji,
    int? availability,
    bool? isPopular,
    bool? isLimited,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      pointsCost: pointsCost ?? this.pointsCost,
      originalValue: originalValue ?? this.originalValue,
      discount: discount ?? this.discount,
      emoji: emoji ?? this.emoji,
      availability: availability ?? this.availability,
      isPopular: isPopular ?? this.isPopular,
      isLimited: isLimited ?? this.isLimited,
    );
  }
}

// Sample data
final List<Map<String, String>> _categories = [
  {'id': 'vouchers', 'label': 'Vouchers', 'emoji': '🎁'},
  {'id': 'cashback', 'label': 'Cashback', 'emoji': '💰'},
  {'id': 'experiences', 'label': 'Experiences', 'emoji': '🎭'},
  {'id': 'digital', 'label': 'Digital', 'emoji': '📱'},
];

final List<ShopItem> _shopItems = [
  ShopItem(
    id: '1',
    name: 'Grab Food Voucher',
    description: 'RM 20 off on food delivery',
    category: 'vouchers',
    pointsCost: 150,
    originalValue: 'RM 20',
    discount: 25,
    emoji: '🍔',
    availability: 50,
    isPopular: true,
  ),
  ShopItem(
    id: '2',
    name: 'Starbucks Voucher',
    description: 'RM 15 Starbucks gift card',
    category: 'vouchers',
    pointsCost: 120,
    originalValue: 'RM 15',
    discount: 20,
    emoji: '☕',
    availability: 30,
  ),
  ShopItem(
    id: '3',
    name: 'Shopee Voucher',
    description: 'RM 30 shopping voucher',
    category: 'vouchers',
    pointsCost: 250,
    originalValue: 'RM 30',
    discount: 17,
    emoji: '🛍️',
    availability: 25,
    isLimited: true,
  ),
  ShopItem(
    id: '4',
    name: 'Cashback',
    description: 'Direct cash to your account',
    category: 'cashback',
    pointsCost: 100,
    originalValue: 'RM 10',
    discount: 0,
    emoji: '💰',
    availability: 100,
  ),
  ShopItem(
    id: '5',
    name: 'Touch n Go eWallet',
    description: 'RM 25 TnG reload',
    category: 'digital',
    pointsCost: 200,
    originalValue: 'RM 25',
    discount: 20,
    emoji: '📱',
    availability: 40,
    isPopular: true,
  ),
  ShopItem(
    id: '6',
    name: 'Cinema Tickets',
    description: '2x GSC movie tickets',
    category: 'experiences',
    pointsCost: 300,
    originalValue: 'RM 40',
    discount: 25,
    emoji: '🎬',
    availability: 15,
    isLimited: true,
  ),
];
