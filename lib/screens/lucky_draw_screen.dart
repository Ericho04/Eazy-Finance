import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class LuckyDrawScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LuckyDrawScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _floatingController;
  bool _isSpinning = false;
  double _currentRotation = 0;
  Prize? _wonPrize;
  bool _showResult = false;
  int _dailySpins = 2;
  List<Prize> _spinHistory = [];

  final int _spinCost = 50;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  bool get _canSpin {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return _dailySpins > 0 || appProvider.rewardPoints >= _spinCost;
  }

  Prize _getRandomPrize() {
    final random = math.Random();
    final randomValue = random.nextDouble() * 100;
    double cumulative = 0;

    for (final prize in _prizes) {
      cumulative += prize.probability;
      if (randomValue <= cumulative) {
        return prize;
      }
    }

    return _prizes.last; // Fallback
  }

  void _spin() async {
    if (!_canSpin || _isSpinning) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    setState(() {
      _isSpinning = true;
      _showResult = false;
    });

    // Deduct cost
    if (_dailySpins > 0) {
      setState(() {
        _dailySpins -= 1;
      });
    } else {
      appProvider.spendRewardPoints(_spinCost);
    }

    // Get random prize
    final prize = _getRandomPrize();
    setState(() {
      _wonPrize = prize;
    });

    // Calculate final rotation
    final prizeIndex = _prizes.indexOf(prize);
    final segmentAngle = 360 / _prizes.length;
    final prizeAngle = prizeIndex * segmentAngle;
    final randomOffset = math.Random().nextDouble() * segmentAngle;
    final finalAngle = 360 * 5 + (360 - prizeAngle - randomOffset);

    setState(() {
      _currentRotation += finalAngle;
    });

    // Animate the spin
    await _spinController.forward();

    // Show result after animation
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSpinning = false;
      _showResult = true;
    });

    // Award prize
    if (prize.type == PrizeType.points) {
      final points = int.parse(prize.value.split(' ')[0]);
      appProvider.addRewardPoints(points);
    }

    // Add to history
    setState(() {
      _spinHistory = [prize, ..._spinHistory.take(4).toList()];
    });

    _spinController.reset();
  }

  String _formatTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    return '${hours}h ${minutes}m';
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
            const Color(0xFFE0E7FF),
            const Color(0xFFFDF4FF),
            const Color(0xFFFFF7ED),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return Column(
                      children: [
                        // Header
                        Row(
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

                            Container(
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Title
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: math.sin(_floatingController.value * 2 * math.pi) * 0.1,
                              child: const Text(
                                '🎰',
                                style: TextStyle(fontSize: 80),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lucky Draw',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Spin the wheel and win amazing prizes!',
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Spin Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.card_giftcard,
                                    color: isDarkMode ? Colors.green.shade300 : Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_dailySpins free spins left',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.green.shade300 : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.blue.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Next: ${_dailySpins > 0 ? 'FREE' : '$_spinCost pts'}',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.blue.shade300 : Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Spinning Wheel
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Wheel
                              AnimatedBuilder(
                                animation: _spinController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: (_currentRotation + _spinController.value * 360 * 5) * math.pi / 180,
                                    child: Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDarkMode
                                              ? SFMSTheme.darkBgSecondary
                                              : Colors.white,
                                          width: 8,
                                        ),
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
                                      child: CustomPaint(
                                        painter: WheelPainter(prizes: _prizes),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Center circle
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  shape: BoxShape.circle,
                                  boxShadow: isDarkMode
                                      ? [
                                          BoxShadow(
                                            color: SFMSTheme.darkAccentTeal.withOpacity(0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: AnimatedBuilder(
                                  animation: _floatingController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _isSpinning
                                          ? _floatingController.value * 2 * math.pi * 4
                                          : 0,
                                      child: Icon(
                                        Icons.auto_awesome,
                                        color: isDarkMode
                                            ? SFMSTheme.darkAccentTeal
                                            : const Color(0xFF845EC2),
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Pointer
                              Positioned(
                                top: 0,
                                child: SizedBox(
                                  width: 0,
                                  height: 0,
                                  child: CustomPaint(
                                    painter: PointerPainter(isDarkMode: isDarkMode),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Spin Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _canSpin && !_isSpinning ? _spin : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canSpin && !_isSpinning
                                  ? SFMSTheme.cartoonPurple
                                  : (isDarkMode
                                      ? SFMSTheme.darkBgTertiary
                                      : Colors.grey.shade300),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isSpinning)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.card_giftcard,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _isSpinning
                                      ? 'Spinning...'
                                      : _dailySpins > 0
                                      ? 'Spin FREE!'
                                      : 'Spin ($_spinCost pts)',
                                  style: TextStyle(
                                    color: _canSpin && !_isSpinning
                                        ? Colors.white
                                        : (isDarkMode ? textMuted : Colors.grey.shade600),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Spin History
                        if (_spinHistory.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.emoji_events,
                                      color: isDarkMode
                                          ? Colors.amber.shade300
                                          : Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Recent Wins',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Column(
                                  children: _spinHistory.map((prize) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? SFMSTheme.darkBgTertiary.withOpacity(0.3)
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            prize.emoji,
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  prize.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  prize.value,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Won',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.green.shade300
                                                    : Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Reset Timer
                        Text(
                          'Free spins reset in: ${_formatTimeUntilReset()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Result modal overlay
          if (_showResult && _wonPrize != null)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
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
                        _wonPrize!.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You won:',
                        style: TextStyle(
                          fontSize: 16,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _wonPrize!.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        _wonPrize!.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? SFMSTheme.darkAccentTeal
                              : SFMSTheme.cartoonPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _wonPrize!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showResult = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? SFMSTheme.darkAccentTeal
                                : SFMSTheme.cartoonPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Awesome! 🎉',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

// Prize model
class Prize {
  final String id;
  final String name;
  final String description;
  final PrizeType type;
  final String value;
  final double probability;
  final String emoji;
  final List<Color> colors;

  Prize({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.probability,
    required this.emoji,
    required this.colors,
  });
}

enum PrizeType { voucher, points, cashback, gift }

final List<Prize> _prizes = [
  Prize(
    id: '1',
    name: 'Cashback',
    description: 'Get money back',
    type: PrizeType.cashback,
    value: 'RM 10',
    probability: 25,
    emoji: '💰',
    colors: [SFMSTheme.successColor, Colors.green.shade600],
  ),
  Prize(
    id: '2',
    name: 'Grab Voucher',
    description: 'Food delivery voucher',
    type: PrizeType.voucher,
    value: 'RM 20',
    probability: 20,
    emoji: '🍔',
    colors: [SFMSTheme.cartoonOrange, Colors.red.shade500],
  ),
  Prize(
    id: '3',
    name: 'Bonus Points',
    description: 'Extra reward points',
    type: PrizeType.points,
    value: '100 pts',
    probability: 30,
    emoji: '⭐',
    colors: [SFMSTheme.cartoonYellow, SFMSTheme.cartoonOrange],
  ),
  Prize(
    id: '4',
    name: 'Coffee Voucher',
    description: 'Starbucks voucher',
    type: PrizeType.voucher,
    value: 'RM 15',
    probability: 15,
    emoji: '☕',
    colors: [Colors.amber.shade400, Colors.yellow.shade500],
  ),
  Prize(
    id: '5',
    name: 'Mega Points',
    description: 'Huge point bonus',
    type: PrizeType.points,
    value: '500 pts',
    probability: 5,
    emoji: '💎',
    colors: [SFMSTheme.cartoonPurple, SFMSTheme.cartoonPink],
  ),
  Prize(
    id: '6',
    name: 'Shopping Voucher',
    description: 'Shopee voucher',
    type: PrizeType.voucher,
    value: 'RM 30',
    probability: 3,
    emoji: '🛍️',
    colors: [SFMSTheme.cartoonPink, SFMSTheme.cartoonPurple],
  ),
  Prize(
    id: '7',
    name: 'Try Again',
    description: 'Better luck next time',
    type: PrizeType.points,
    value: '5 pts',
    probability: 2,
    emoji: '🔄',
    colors: [Colors.grey.shade400, Colors.grey.shade500],
  ),
];

// Custom painter for the wheel
class WheelPainter extends CustomPainter {
  final List<Prize> prizes;

  WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      final paint = Paint()
        ..shader = LinearGradient(
          colors: prizes[i].colors,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      // Draw segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw text
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + math.cos(textAngle) * textRadius;
      final textY = center.dy + math.sin(textAngle) * textRadius;

      final textPainter = TextPainter(
        text: TextSpan(
          text: prizes[i].emoji,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textX - textPainter.width / 2,
          textY - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the pointer
class PointerPainter extends CustomPainter {
  final bool isDarkMode;

  PointerPainter({this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? SFMSTheme.darkBgSecondary : Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(-15, 30);
    path.lineTo(15, 30);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()
      ..color = isDarkMode
          ? SFMSTheme.darkBgTertiary
          : Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
