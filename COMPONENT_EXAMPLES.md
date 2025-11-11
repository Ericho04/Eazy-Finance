# Component Usage Examples
## Modern Flat-Vector Cartoon UI Components

This guide shows how to use the modern UI components from `/lib/widget/modern_ui_components.dart` throughout your Eazy-Finance app.

---

## 📦 Import

```dart
import 'package:sfms_flutter/widget/modern_ui_components.dart';
import 'package:sfms_flutter/utils/theme.dart';
```

---

## 💰 Balance Card

Display account balance with gradient background.

### Basic Usage
```dart
BalanceCard(
  title: 'Total Balance',
  amount: '\$12,450.80',
  subtitle: '+\$1,234.50 this month',
  gradient: SFMSTheme.primaryGradient,
  onTap: () {
    // Navigate to account details
  },
)
```

### With Different Palettes
```dart
// Success/Income Balance
BalanceCard(
  title: 'Total Income',
  amount: '\$8,450.00',
  gradient: SFMSTheme.accentGradient,
)

// Gold/Premium Balance
BalanceCard(
  title: 'Rewards Balance',
  amount: '2,450 pts',
  gradient: SFMSTheme.goldGradient,
)
```

---

## 🎯 Category Icon

Circular icons with gradients for categories.

### Basic Usage
```dart
CategoryIcon(
  emoji: '🍔',
  gradient: SFMSTheme.cartoonOrangeGradient,
  size: 48,
  emojiSize: 24,
)
```

### Different Sizes
```dart
// Small (for list items)
CategoryIcon(emoji: '🚗', gradient: SFMSTheme.cartoonBlueGradient, size: 40, emojiSize: 20)

// Medium (default)
CategoryIcon(emoji: '🛍️', gradient: SFMSTheme.cartoonPinkGradient, size: 48, emojiSize: 24)

// Large (for featured categories)
CategoryIcon(emoji: '🎬', gradient: SFMSTheme.cartoonPurpleGradient, size: 64, emojiSize: 32)
```

### Using Theme Categories
```dart
// From expense categories
final foodCategory = SFMSTheme.expenseCategories[0];
CategoryIcon(
  emoji: foodCategory['emoji'],
  gradient: foodCategory['gradient'],
)

// From income categories
final salaryCategory = SFMSTheme.incomeCategories[0];
CategoryIcon(
  emoji: salaryCategory['emoji'],
  gradient: salaryCategory['gradient'],
)
```

---

## 📊 Stat Card

Compact statistics with icons and trends.

### Basic Usage
```dart
StatCard(
  label: 'Total Spending',
  value: '\$3,240',
  icon: Icons.trending_down_rounded,
  color: SFMSTheme.primaryColor,
  trend: '12% less than last month',
  isPositive: true,
)
```

### Grid Layout Example
```dart
GridView.count(
  crossAxisCount: 2,
  childAspectRatio: 1.4,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  children: [
    StatCard(
      label: 'Income',
      value: '\$5,200',
      icon: Icons.arrow_upward_rounded,
      color: SFMSTheme.successColor,
    ),
    StatCard(
      label: 'Expenses',
      value: '\$3,240',
      icon: Icons.arrow_downward_rounded,
      color: SFMSTheme.dangerColor,
    ),
    StatCard(
      label: 'Savings',
      value: '\$1,960',
      icon: Icons.savings_rounded,
      color: SFMSTheme.accentColor,
      trend: '+15%',
      isPositive: true,
    ),
    StatCard(
      label: 'Budget Left',
      value: '\$760',
      icon: Icons.account_balance_wallet_rounded,
      color: SFMSTheme.warningColor,
      trend: '23% used',
      isPositive: false,
    ),
  ],
)
```

---

## 🎖️ Progress Indicator Card

Show progress towards goals or budgets.

### Linear Progress
```dart
ProgressIndicatorCard(
  title: 'Emergency Fund',
  currentAmount: '\$3,500',
  targetAmount: '\$10,000',
  progress: 0.35,
  emoji: '🏦',
  isCircular: false,
)
```

### Circular Progress
```dart
ProgressIndicatorCard(
  title: 'Vacation Savings',
  currentAmount: '\$2,800',
  targetAmount: '\$5,000',
  progress: 0.56,
  emoji: '✈️',
  isCircular: true,
)
```

### Budget Usage Example
```dart
final budget = budgets[0];
final utilizationPercentage = (budget.spent / budget.amount);

ProgressIndicatorCard(
  title: budget.category,
  currentAmount: '\$${budget.spent.toStringAsFixed(2)}',
  targetAmount: '\$${budget.amount.toStringAsFixed(2)}',
  progress: utilizationPercentage,
  emoji: '💰',
)
```

---

## 🏷️ Status Badge

Small badges for status indicators.

### Basic Usage
```dart
StatusBadge(
  text: 'On Track',
  color: SFMSTheme.successColor,
  icon: Icons.check_circle,
)
```

### Different States
```dart
// Success State
StatusBadge(text: 'Completed', color: SFMSTheme.successColor, filled: true)

// Warning State
StatusBadge(text: 'Nearly Over', color: SFMSTheme.warningColor, icon: Icons.warning_rounded)

// Danger State
StatusBadge(text: 'Over Budget', color: SFMSTheme.dangerColor, filled: true, icon: Icons.error)

// Info State
StatusBadge(text: 'In Progress', color: SFMSTheme.infoColor)
```

### In List Items
```dart
ListTile(
  title: Text('Monthly Budget'),
  subtitle: Text('Food & Dining'),
  trailing: StatusBadge(
    text: '${utilizationPercentage.toInt()}% Used',
    color: SFMSTheme.getStatusColor(utilizationPercentage),
  ),
)
```

---

## 💡 AI Tip Card

Display AI-powered financial tips.

### Basic Usage
```dart
AiTipCardModern(
  title: 'Save More This Month',
  description: 'You could save \$250 more by reducing dining expenses by 20%.',
  icon: Icons.lightbulb_outline_rounded,
  onTap: () {
    // Show detailed tip
  },
)
```

### Different Tip Types
```dart
// Savings Tip
AiTipCardModern(
  title: 'Savings Opportunity',
  description: 'Transfer \$100 to your emergency fund today.',
  icon: Icons.savings_outlined,
)

// Budget Alert
AiTipCardModern(
  title: 'Budget Alert',
  description: 'You\'re approaching your entertainment budget limit.',
  icon: Icons.notifications_outlined,
)

// Investment Insight
AiTipCardModern(
  title: 'Smart Investment',
  description: 'Consider investing your surplus \$500 in a high-yield savings account.',
  icon: Icons.trending_up_rounded,
)
```

---

## 📋 Transaction List Item

Modern transaction list with category icons.

### Basic Usage
```dart
TransactionListItem(
  category: 'Food & Dining',
  emoji: '🍔',
  description: 'Lunch at Italian Restaurant',
  amount: '\$45.80',
  date: 'Today, 12:30 PM',
  isIncome: false,
  categoryGradient: SFMSTheme.cartoonOrangeGradient,
  onTap: () {
    // Show transaction details
  },
)
```

### Using Transaction Model
```dart
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    final transaction = transactions[index];
    final category = transaction.type == 'income'
        ? SFMSTheme.incomeCategories.firstWhere((c) => c['id'] == transaction.category)
        : SFMSTheme.expenseCategories.firstWhere((c) => c['id'] == transaction.category);

    return TransactionListItem(
      category: category['name'],
      emoji: category['emoji'],
      description: transaction.description,
      amount: '\$${transaction.amount.toStringAsFixed(2)}',
      date: DateFormat('MMM d, h:mm a').format(transaction.date),
      isIncome: transaction.type == 'income',
      categoryGradient: category['gradient'],
      onTap: () => _showTransactionDetails(transaction),
    );
  },
)
```

---

## 🎨 Quick Action Button

Rounded buttons for quick actions.

### Basic Usage
```dart
QuickActionButton(
  label: 'Add Expense',
  icon: Icons.add_rounded,
  gradient: SFMSTheme.primaryGradient,
  onPressed: () {
    // Navigate to add expense
  },
)
```

### Action Row Example
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    QuickActionButton(
      label: 'Add Income',
      icon: Icons.add_circle_outline_rounded,
      gradient: SFMSTheme.successGradient,
      onPressed: () {},
    ),
    QuickActionButton(
      label: 'Add Expense',
      icon: Icons.remove_circle_outline_rounded,
      gradient: SFMSTheme.dangerGradient,
      onPressed: () {},
    ),
  ],
)
```

### Solid Color Variant
```dart
QuickActionButton(
  label: 'Scan Receipt',
  icon: Icons.camera_alt_rounded,
  backgroundColor: SFMSTheme.cartoonPurple,
  onPressed: () {},
)
```

---

## 🏆 Achievement Badge

Badge-style illustrations for achievements.

### Basic Usage
```dart
AchievementBadge(
  title: 'First Savings Goal',
  emoji: '🎯',
  description: 'Completed your first savings goal!',
  isUnlocked: true,
  onTap: () {
    // Show achievement details
  },
)
```

### Grid of Achievements
```dart
GridView.count(
  crossAxisCount: 3,
  childAspectRatio: 0.85,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  children: [
    AchievementBadge(title: 'Budget Master', emoji: '💰', isUnlocked: true),
    AchievementBadge(title: 'Savings Star', emoji: '⭐', isUnlocked: true),
    AchievementBadge(title: 'Investment Pro', emoji: '📈', isUnlocked: false),
    AchievementBadge(title: 'Debt Free', emoji: '🎊', description: 'Pay off all debts', isUnlocked: false),
  ],
)
```

### Dynamic Achievement System
```dart
final achievements = [
  {'id': 'first_budget', 'title': 'First Budget', 'emoji': '📊', 'unlocked': true},
  {'id': 'week_saver', 'title': 'Week Saver', 'emoji': '🔥', 'unlocked': true},
  {'id': 'month_goal', 'title': 'Monthly Goal', 'emoji': '🏆', 'unlocked': false},
];

Wrap(
  spacing: 12,
  runSpacing: 12,
  children: achievements.map((achievement) {
    return AchievementBadge(
      title: achievement['title'],
      emoji: achievement['emoji'],
      isUnlocked: achievement['unlocked'],
      onTap: () => _showAchievementDetails(achievement),
    );
  }).toList(),
)
```

---

## 🎬 Complete Screen Examples

### Dashboard Screen
```dart
class ModernDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SFMSTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Balance Card
              BalanceCard(
                title: 'Total Balance',
                amount: '\$12,450.80',
                subtitle: '+\$1,234.50 this month',
                gradient: SFMSTheme.primaryGradient,
              ),

              SizedBox(height: SFMSTheme.spacing24),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      label: 'Add Income',
                      icon: Icons.add_circle_outline,
                      gradient: SFMSTheme.successGradient,
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: SFMSTheme.spacing12),
                  Expanded(
                    child: QuickActionButton(
                      label: 'Add Expense',
                      icon: Icons.remove_circle_outline,
                      gradient: SFMSTheme.dangerGradient,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: SFMSTheme.spacing24),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  StatCard(label: 'Income', value: '\$5,200', icon: Icons.arrow_upward, color: SFMSTheme.successColor),
                  StatCard(label: 'Expenses', value: '\$3,240', icon: Icons.arrow_downward, color: SFMSTheme.dangerColor),
                  StatCard(label: 'Savings', value: '\$1,960', icon: Icons.savings, color: SFMSTheme.accentColor),
                  StatCard(label: 'Budget Left', value: '\$760', icon: Icons.account_balance_wallet, color: SFMSTheme.warningColor),
                ],
              ),

              SizedBox(height: SFMSTheme.spacing24),

              // AI Tip
              AiTipCardModern(
                title: 'Smart Savings Tip',
                description: 'You could save \$250 more by reducing dining expenses.',
                onTap: () {},
              ),

              SizedBox(height: SFMSTheme.spacing24),

              // Recent Transactions
              Text('Recent Transactions', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: SFMSTheme.spacing12),

              TransactionListItem(
                category: 'Food & Dining',
                emoji: '🍔',
                description: 'Italian Restaurant',
                amount: '\$45.80',
                date: 'Today',
                isIncome: false,
                categoryGradient: SFMSTheme.cartoonOrangeGradient,
              ),
              // More transactions...
            ],
          ),
        ),
      ),
    );
  }
}
```

### Goals Screen
```dart
class ModernGoalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Goals')),
      body: ListView(
        padding: EdgeInsets.all(SFMSTheme.spacing16),
        children: [
          ProgressIndicatorCard(
            title: 'Emergency Fund',
            currentAmount: '\$3,500',
            targetAmount: '\$10,000',
            progress: 0.35,
            emoji: '🏦',
            isCircular: false,
          ),

          SizedBox(height: SFMSTheme.spacing16),

          ProgressIndicatorCard(
            title: 'Vacation Savings',
            currentAmount: '\$2,800',
            targetAmount: '\$5,000',
            progress: 0.56,
            emoji: '✈️',
            isCircular: true,
          ),

          SizedBox(height: SFMSTheme.spacing24),

          Text('Achievements', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: SFMSTheme.spacing16),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              AchievementBadge(title: 'First Goal', emoji: '🎯', isUnlocked: true),
              AchievementBadge(title: 'Saver', emoji: '⭐', isUnlocked: true),
              AchievementBadge(title: 'Investor', emoji: '📈', isUnlocked: false),
              AchievementBadge(title: 'Debt Free', emoji: '🎊', isUnlocked: false),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 🎨 Color Palette Switching

To test different color palettes, update `/lib/utils/theme.dart`:

```dart
// Switch to Palette 2 (Teal Prosperity)
static const Color primaryColor = palette2Primary;
static const Color primaryLight = palette2PrimaryLight;
static const Color accentColor = palette2Accent;
static const Color accentAlt = palette2AccentAlt;
static const Color backgroundColor = palette2Surface;
static const Color backgroundVariant = palette2SurfaceVariant;
```

All components will automatically use the new colors!

---

## 📱 Responsive Design Tips

### Mobile-First Sizing
```dart
// Use MediaQuery for responsive sizing
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 360;

BalanceCard(
  title: 'Balance',
  amount: '\$12,450',
  // Adjust padding on small screens
  // You can customize the component or wrap it
)
```

### Adaptive Grids
```dart
// Adapt grid columns based on screen size
GridView.count(
  crossAxisCount: screenWidth > 600 ? 3 : 2,
  children: [/* stat cards */],
)
```

---

## ✨ Animation Tips

### Add entrance animations
```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

AnimationLimiter(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: TransactionListItem(/* ... */),
          ),
        ),
      );
    },
  ),
)
```

---

**For more information, see [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)**
