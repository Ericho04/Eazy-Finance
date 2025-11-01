// lib/widgets/ai_tip_card.dart
import 'package:flutter/material.dart';

class AiTipCard extends StatelessWidget {
  final String title;
  final String tip;
  final IconData icon;
  final Color color;

  const AiTipCard({
    Key? key,
    required this.title,
    required this.tip,
    this.icon = Icons.lightbulb_outline,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // 添加一个淡入动画，使 AI 文本加载更平滑
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    tip,
                    key: ValueKey<String>(tip), // 确保文本更改时触发动画
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}