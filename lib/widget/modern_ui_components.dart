import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Modern flat-vector cartoon UI components for Eazy-Finance
/// Implements professional, trustworthy, and friendly design patterns

// ==========================================================================
// 💰 BALANCE CARD
// Hero card displaying account balance with gradient background
// ==========================================================================

class BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const BalanceCard({
    Key? key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SFMSTheme.spacing24),
        decoration: BoxDecoration(
          gradient: gradient ?? SFMSTheme.primaryGradient,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.accentShadow(
            gradient?.colors.first ?? SFMSTheme.primaryColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            SizedBox(height: SFMSTheme.spacing8),
            Text(
              amount,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: SFMSTheme.spacing4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 🎯 CATEGORY ICON
// Circular icon with gradient background for expense/income categories
// ==========================================================================

class CategoryIcon extends StatelessWidget {
  final String emoji;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final double size;
  final double emojiSize;

  const CategoryIcon({
    Key? key,
    required this.emoji,
    this.gradient,
    this.backgroundColor,
    this.size = 48.0,
    this.emojiSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: emojiSize),
        ),
      ),
    );
  }
}

// ==========================================================================
// 📊 STAT CARD
// Compact card showing a statistic with icon and trend
// ==========================================================================

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? trend;
  final bool isPositive;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.isPositive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? SFMSTheme.primaryColor;

    return Container(
      padding: EdgeInsets.all(SFMSTheme.spacing16),
      decoration: BoxDecoration(
        color: SFMSTheme.cardColor,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
        boxShadow: SFMSTheme.softCardShadow,
        border: Border.all(
          color: effectiveColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: effectiveColor, size: SFMSTheme.iconSizeMedium),
              SizedBox(width: SFMSTheme.spacing8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SFMSTheme.textSecondary,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: SFMSTheme.spacing12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: SFMSTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (trend != null) ...[
            SizedBox(height: SFMSTheme.spacing4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: isPositive ? SFMSTheme.successColor : SFMSTheme.dangerColor,
                ),
                SizedBox(width: SFMSTheme.spacing4),
                Text(
                  trend!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPositive ? SFMSTheme.successColor : SFMSTheme.dangerColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================================================
// 🎖️ PROGRESS INDICATOR
// Circular or linear progress with status coloring
// ==========================================================================

class ProgressIndicatorCard extends StatelessWidget {
  final String title;
  final String currentAmount;
  final String targetAmount;
  final double progress; // 0.0 to 1.0
  final bool isCircular;
  final String? emoji;

  const ProgressIndicatorCard({
    Key? key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.progress,
    this.isCircular = false,
    this.emoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100);
    final statusColor = SFMSTheme.getStatusColor(percentage);
    final statusGradient = SFMSTheme.getStatusGradient(percentage);

    return Container(
      padding: EdgeInsets.all(SFMSTheme.spacing20),
      decoration: BoxDecoration(
        color: SFMSTheme.cardColor,
        borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
        boxShadow: SFMSTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: TextStyle(fontSize: 24)),
                SizedBox(width: SFMSTheme.spacing12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SFMSTheme.spacing12,
                  vertical: SFMSTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SFMSTheme.radiusFull),
                ),
                child: Text(
                  '${percentage.toInt()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: SFMSTheme.spacing16),
          if (isCircular)
            _buildCircularProgress(context, percentage, statusColor)
          else
            _buildLinearProgress(context, percentage, statusGradient),
          SizedBox(height: SFMSTheme.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SFMSTheme.textSecondary,
                        ),
                  ),
                  Text(
                    currentAmount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SFMSTheme.textSecondary,
                        ),
                  ),
                  Text(
                    targetAmount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: SFMSTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinearProgress(
    BuildContext context,
    double percentage,
    LinearGradient gradient,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SFMSTheme.radiusFull),
      child: SizedBox(
        height: 12,
        child: Stack(
          children: [
            Container(color: SFMSTheme.neutralLight),
            FractionallySizedBox(
              widthFactor: progress.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(gradient: gradient),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(
    BuildContext context,
    double percentage,
    Color color,
  ) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 12,
                backgroundColor: SFMSTheme.neutralLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percentage.toInt()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'Complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SFMSTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 🏷️ STATUS BADGE
// Small badge with status color and text
// ==========================================================================

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  final bool filled;

  const StatusBadge({
    Key? key,
    required this.text,
    this.color,
    this.icon,
    this.filled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? SFMSTheme.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SFMSTheme.spacing12,
        vertical: SFMSTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: filled ? effectiveColor : effectiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SFMSTheme.radiusFull),
        border: filled
            ? null
            : Border.all(
                color: effectiveColor,
                width: 1.5,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: filled ? Colors.white : effectiveColor,
            ),
            SizedBox(width: SFMSTheme.spacing4),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: filled ? Colors.white : effectiveColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// 💡 AI TIP CARD
// Card displaying AI-powered financial tips with gradient
// ==========================================================================

class AiTipCardModern extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const AiTipCardModern({
    Key? key,
    required this.title,
    required this.description,
    this.icon = Icons.lightbulb_outline_rounded,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SFMSTheme.spacing20),
        decoration: BoxDecoration(
          gradient: SFMSTheme.aiGradient,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
          boxShadow: SFMSTheme.accentShadow(SFMSTheme.aiPrimary),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SFMSTheme.spacing12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: SFMSTheme.iconSizeLarge,
              ),
            ),
            SizedBox(width: SFMSTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: SFMSTheme.spacing4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 📋 TRANSACTION LIST ITEM
// Modern list item for transactions with category icon
// ==========================================================================

class TransactionListItem extends StatelessWidget {
  final String category;
  final String emoji;
  final String description;
  final String amount;
  final String date;
  final bool isIncome;
  final LinearGradient? categoryGradient;
  final VoidCallback? onTap;

  const TransactionListItem({
    Key? key,
    required this.category,
    required this.emoji,
    required this.description,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.categoryGradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: SFMSTheme.spacing16,
        vertical: SFMSTheme.spacing8,
      ),
      leading: CategoryIcon(
        emoji: emoji,
        gradient: categoryGradient,
        size: 48,
        emojiSize: 24,
      ),
      title: Text(
        description,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        '$category · $date',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SFMSTheme.textSecondary,
            ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'} $amount',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isIncome ? SFMSTheme.successColor : SFMSTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ==========================================================================
// 🎨 QUICK ACTION BUTTON
// Rounded button for quick actions with icon and label
// ==========================================================================

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  const QuickActionButton({
    Key? key,
    required this.label,
    required this.icon,
    this.gradient,
    this.backgroundColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SFMSTheme.spacing20,
          vertical: SFMSTheme.spacing16,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? (backgroundColor ?? SFMSTheme.primaryColor) : null,
          borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
          boxShadow: SFMSTheme.softCardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: SFMSTheme.iconSizeMedium),
            SizedBox(width: SFMSTheme.spacing8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 🏆 ACHIEVEMENT BADGE
// Badge-style illustration for achievements and milestones
// ==========================================================================

class AchievementBadge extends StatelessWidget {
  final String title;
  final String emoji;
  final String? description;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    Key? key,
    required this.title,
    required this.emoji,
    this.description,
    this.isUnlocked = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Container(
          padding: EdgeInsets.all(SFMSTheme.spacing16),
          decoration: BoxDecoration(
            gradient: isUnlocked ? SFMSTheme.goldGradient : null,
            color: isUnlocked ? null : SFMSTheme.neutralLight,
            borderRadius: BorderRadius.circular(SFMSTheme.radiusLarge),
            boxShadow: isUnlocked ? SFMSTheme.accentShadow(SFMSTheme.accentAlt) : null,
            border: isUnlocked
                ? null
                : Border.all(color: SFMSTheme.neutralMedium, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.white.withOpacity(0.2) : SFMSTheme.neutralMedium,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              SizedBox(height: SFMSTheme.spacing12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isUnlocked ? Colors.white : SFMSTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                SizedBox(height: SFMSTheme.spacing4),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUnlocked ? Colors.white.withOpacity(0.9) : SFMSTheme.textMuted,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
