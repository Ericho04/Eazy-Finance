# Eazy-Finance Design System
## Modern Flat-Vector Cartoon Style for Financial Apps

---

## Overview

This design system implements a **professional, trustworthy, and friendly** flat-vector cartoon style inspired by modern fintech apps like **Wealthsimple**, **Plum**, and **Revolut**. The design balances approachability with financial credibility through carefully chosen colors, typography, and visual elements.

---

## 🎨 Color Palette Variations

### How to Switch Palettes

To change the active palette, edit `/lib/utils/theme.dart` and update these lines:

```dart
static const Color primaryColor = palette1Primary;  // Change to palette2Primary or palette3Primary
static const Color primaryLight = palette1PrimaryLight;
static const Color accentColor = palette1Accent;
static const Color accentAlt = palette1AccentAlt;
static const Color backgroundColor = palette1Surface;
static const Color backgroundVariant = palette1SurfaceVariant;
```

---

### Palette 1: Deep Blue Trust (DEFAULT)

**Theme:** Professional, trustworthy, calm - ideal for financial security

| Color | Hex | Usage |
|-------|-----|-------|
| Primary (Deep Blue) | `#1E3A8A` | Main brand color, primary buttons, headers |
| Primary Light (Light Blue) | `#3B82F6` | Interactive elements, links |
| Accent (Success Green) | `#10B981` | Positive actions, success states, income |
| Accent Alt (Gold) | `#FACC15` | Premium features, rewards, highlights |
| Surface (Soft White) | `#F8FAFC` | Background color |
| Surface Variant (Light Blue Tint) | `#EFF6FF` | Secondary backgrounds |

**Best for:** Traditional banking apps, investment platforms, retirement planning

---

### Palette 2: Teal Prosperity

**Theme:** Fresh, modern, growth-oriented - emphasizes financial growth

| Color | Hex | Usage |
|-------|-----|-------|
| Primary (Teal) | `#0D9488` | Main brand color |
| Primary Light (Light Teal) | `#14B8A6` | Interactive elements |
| Accent (Gold) | `#FACC15` | Rewards, achievements |
| Accent Alt (Green) | `#10B981` | Success indicators |
| Surface (Mint Tint) | `#F0FDFA` | Background color |
| Surface Variant (Light Teal Tint) | `#CCFBF1` | Secondary backgrounds |

**Best for:** Savings apps, budgeting tools, financial growth tracking

---

### Palette 3: Royal Indigo Confidence

**Theme:** Sophisticated, premium, confident - for high-value financial apps

| Color | Hex | Usage |
|-------|-----|-------|
| Primary (Royal Indigo) | `#4338CA` | Main brand color |
| Primary Light (Light Indigo) | `#6366F1` | Interactive elements |
| Accent (Success Green) | `#10B981` | Success indicators |
| Accent Alt (Amber/Gold) | `#F59E0B` | Premium features |
| Surface (Soft Purple Tint) | `#FAF5FF` | Background color |
| Surface Variant (Light Indigo Tint) | `#EDE9FE` | Secondary backgrounds |

**Best for:** Wealth management, premium banking, investment advisory

---

## 🎯 Universal Status Colors

These colors remain consistent across all palettes:

| Status | Color | Hex | Usage |
|--------|-------|-----|-------|
| Success | Green | `#10B981` | Completed actions, positive balance, income |
| Warning | Amber | `#F59E0B` | Budget alerts, moderate risk |
| Danger | Red | `#EF4444` | Over-budget, errors, critical alerts |
| Info | Blue | `#3B82F6` | Informational messages, tips |

---

## 🖌️ Flat-Vector Cartoon Accent Colors

Professional, softer versions for category icons and illustrations:

| Name | Color | Hex | Usage |
|------|-------|-----|-------|
| Soft Mint | 🟢 | `#6EE7B7` | Groceries, health, nature |
| Sky Blue | 🔵 | `#60A5FA` | Transportation, tech, utilities |
| Lavender | 🟣 | `#A78BFA` | Entertainment, creative, freelance |
| Rose Pink | 🔴 | `#F472B6` | Shopping, personal care, gifts |
| Sunny Yellow | 🟡 | `#FBBF24` | Bonuses, rewards, education |
| Peach Orange | 🟠 | `#FB923C` | Food, dining, lifestyle |
| Cyan | 🔷 | `#22D3EE` | Investments, analytics |
| Teal | 🟦 | `#2DD4BF` | Rental income, passive income |

---

## ✍️ Typography System

### Font Weights
- **Extra Bold** (`w800`): Hero numbers, large balance displays
- **Bold** (`w700`): Section headers, emphasis
- **Semi-Bold** (`w600`): Card titles, button labels
- **Medium** (`w500`): Chips, tags, small labels
- **Regular** (`w400`): Body text, descriptions

### Text Hierarchy

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| **Display Large** | 48px | 800 | Hero balance, main account total |
| **Display Medium** | 36px | 700 | Page headers, major sections |
| **Display Small** | 28px | 700 | Section headers |
| **Headline Large** | 24px | 700 | Card headers, important titles |
| **Headline Medium** | 20px | 600 | Sub-headers |
| **Headline Small** | 18px | 600 | Category titles |
| **Title Large** | 16px | 600 | List item headers |
| **Title Medium** | 14px | 600 | Card subtitles |
| **Title Small** | 13px | 600 | Small labels |
| **Body Large** | 16px | 400 | Main content, descriptions |
| **Body Medium** | 14px | 400 | Secondary content |
| **Body Small** | 12px | 400 | Captions, metadata |
| **Label Large** | 14px | 600 | Primary buttons |
| **Label Medium** | 12px | 500 | Small buttons, chips |
| **Label Small** | 10px | 500 | Tiny tags, badges |

### Letter Spacing & Line Height
- **Display text**: Negative letter-spacing (-1.5 to -0.5) for tighter, modern look
- **Headlines**: Slightly negative to neutral (-0.5 to 0)
- **Body & Labels**: Positive spacing (0.1 to 0.5) for readability
- **Line height**: 1.1-1.2 for headers, 1.4-1.5 for body text

---

## 🎨 Gradients

### Primary Brand Gradients
```dart
SFMSTheme.primaryGradient    // Deep Blue → Light Blue
SFMSTheme.accentGradient     // Green → Light Green
SFMSTheme.goldGradient       // Gold → Yellow
```

### Status Gradients
```dart
SFMSTheme.successGradient    // For positive indicators
SFMSTheme.warningGradient    // For alerts
SFMSTheme.dangerGradient     // For critical items
SFMSTheme.infoGradient       // For informational elements
```

### Background Gradients
```dart
SFMSTheme.backgroundGradientBlue    // Soft blue tint
SFMSTheme.backgroundGradientTeal    // Soft teal tint
SFMSTheme.backgroundGradientPurple  // Soft purple tint
```

### Category Gradients
```dart
SFMSTheme.cartoonMintGradient
SFMSTheme.cartoonBlueGradient
SFMSTheme.cartoonPurpleGradient
SFMSTheme.cartoonPinkGradient
SFMSTheme.cartoonYellowGradient
SFMSTheme.cartoonOrangeGradient
SFMSTheme.cartoonCyanGradient
SFMSTheme.cartoonTealGradient
```

---

## 📐 Spacing & Sizing

### Border Radius
```dart
SFMSTheme.radiusSmall    // 12px - Small cards, chips
SFMSTheme.radiusMedium   // 16px - Buttons, inputs
SFMSTheme.radiusLarge    // 20px - Large buttons, cards
SFMSTheme.radiusXLarge   // 24px - Hero cards, modals
SFMSTheme.radiusFull     // 9999px - Circular elements
```

### Icon Sizes
```dart
SFMSTheme.iconSizeSmall    // 16px - Inline icons
SFMSTheme.iconSizeMedium   // 20px - List icons
SFMSTheme.iconSizeLarge    // 24px - Navigation, headers
SFMSTheme.iconSizeXLarge   // 32px - Category icons
SFMSTheme.iconSizeHero     // 48px - Feature illustrations
```

### Spacing
```dart
SFMSTheme.spacing4    // 4px - Tight spacing
SFMSTheme.spacing8    // 8px - Small gaps
SFMSTheme.spacing12   // 12px - Compact spacing
SFMSTheme.spacing16   // 16px - Default spacing
SFMSTheme.spacing20   // 20px - Comfortable spacing
SFMSTheme.spacing24   // 24px - Large spacing
SFMSTheme.spacing32   // 32px - Section spacing
SFMSTheme.spacing40   // 40px - Major sections
SFMSTheme.spacing48   // 48px - Page sections
```

---

## 🃏 UI Components

### Cards
- **Border Radius:** 24px
- **Elevation:** 0 (flat design)
- **Shadow:** Soft, subtle (4px offset, 12px blur, 4% opacity)
- **Padding:** 16-24px
- **Background:** Pure white or tinted surface color

### Buttons

#### Primary Button
- **Background:** Primary color with gradient option
- **Text:** White, weight 600
- **Border Radius:** 20px
- **Padding:** 32px horizontal, 16px vertical
- **Shadow:** Optional colored shadow for emphasis

#### Outlined Button
- **Border:** 2px solid primary color
- **Text:** Primary color, weight 600
- **Border Radius:** 20px
- **Background:** Transparent

#### Text Button
- **Text:** Primary color, weight 600
- **Border Radius:** 16px
- **Padding:** 24px horizontal, 12px vertical

### Input Fields
- **Background:** Neutral light color
- **Border:** 1.5px when enabled, 2px when focused
- **Border Radius:** 20px
- **Padding:** 20px horizontal, 18px vertical
- **Focus Color:** Primary color
- **Error Color:** Danger color

### Chips & Tags
- **Background:** Neutral light or tinted surface
- **Border Radius:** 16px
- **Padding:** 12px horizontal, 8px vertical
- **Text:** 13px, weight 500

---

## 🎭 Shadows

```dart
// Soft card shadow (flat design)
SFMSTheme.softCardShadow

// Floating element shadow
SFMSTheme.floatingShadow

// Colored accent shadow
SFMSTheme.accentShadow(SFMSTheme.primaryColor)
```

---

## 📊 Data Visualization

### Chart Colors
Use category gradients for charts:
- Income charts: `successGradient` or `accentGradient`
- Expense breakdowns: Category-specific gradients
- Progress indicators: Status gradients based on completion

### Goal & Budget Indicators
```dart
// Automatically returns appropriate color/gradient
SFMSTheme.getStatusColor(utilizationPercentage)
SFMSTheme.getStatusGradient(utilizationPercentage)
```

**Thresholds:**
- 0-49%: Success (Green)
- 50-69%: Info (Blue)
- 70-89%: Warning (Amber)
- 90-100%: Danger (Red)

---

## 🎯 Icon System

### Primary Icons (Material Icons)
- Use rounded variants: `Icons.home_rounded`, `Icons.pie_chart_rounded`
- Consistent sizing with `iconSize` constants
- Solid fills for active states, outlined for inactive

### Category Icons
- Emoji-based for friendly, approachable feel
- Paired with circular colored backgrounds
- Gradient backgrounds for premium categories

---

## 🌙 Dark Theme

The dark theme uses:
- **Background:** Deep navy (`#0A0E27`)
- **Cards:** Lighter navy (`#1A1F3A`)
- **Text:** Soft white/blue (`#E8EAF6`)
- **Accents:** Lighter versions of primary colors
- **Shadows:** More prominent for depth

Dark theme automatically adjusts all colors while maintaining visual hierarchy.

---

## 💡 Best Practices

### DO
- Use gradients sparingly for emphasis
- Maintain consistent spacing with theme constants
- Use semantic color names (success, warning, danger)
- Apply subtle shadows for depth without heaviness
- Keep card corners consistently rounded (24px)
- Use weight hierarchy for text importance

### DON'T
- Mix multiple bright gradients in one view
- Use harsh shadows or excessive elevation
- Use pure black text (use `textPrimary` instead)
- Create custom colors outside the design system
- Use emojis excessively beyond category icons
- Reduce border radius below 12px

---

## 🚀 Implementation Examples

### Creating a Balance Card
```dart
Container(
  padding: EdgeInsets.all(SFMSTheme.spacing24),
  decoration: BoxDecoration(
    gradient: SFMSTheme.primaryGradient,
    borderRadius: BorderRadius.circular(SFMSTheme.radiusXLarge),
    boxShadow: SFMSTheme.accentShadow(SFMSTheme.primaryColor),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Total Balance', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
      SizedBox(height: SFMSTheme.spacing8),
      Text('\$12,450.80', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white)),
    ],
  ),
)
```

### Creating a Category Icon
```dart
Container(
  width: 48,
  height: 48,
  decoration: BoxDecoration(
    gradient: SFMSTheme.cartoonOrangeGradient,
    borderRadius: BorderRadius.circular(SFMSTheme.radiusMedium),
  ),
  child: Center(
    child: Text('🍔', style: TextStyle(fontSize: 24)),
  ),
)
```

### Creating a Status Indicator
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: SFMSTheme.spacing12,
    vertical: SFMSTheme.spacing8,
  ),
  decoration: BoxDecoration(
    color: SFMSTheme.getStatusColor(budgetUtilization).withOpacity(0.1),
    borderRadius: BorderRadius.circular(SFMSTheme.radiusFull),
    border: Border.all(
      color: SFMSTheme.getStatusColor(budgetUtilization),
      width: 1.5,
    ),
  ),
  child: Text(
    '${budgetUtilization.toInt()}% Used',
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: SFMSTheme.getStatusColor(budgetUtilization),
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

---

## 📱 Screen-Specific Guidelines

### Dashboard
- Hero balance card with primary gradient
- Flat-vector spending chart with category colors
- Recent transactions list with category icons
- Quick action buttons with rounded corners

### Budget Screen
- Progress bars with status gradients
- Category breakdown with emoji icons
- Budget health indicators with color coding

### Goals Screen
- Progress circles with gradient fills
- Achievement badges with gold accents
- Target vs. current amount comparison

### Insights Screen
- AI tips card with purple gradient
- Analytics charts with teal/blue tones
- Spending trend visualizations

---

## 🎨 Accessibility

- **Contrast Ratios:** All text meets WCAG AA standards (4.5:1 minimum)
- **Color Independence:** Never rely solely on color to convey information
- **Touch Targets:** Minimum 44x44px for all interactive elements
- **Text Scaling:** Support dynamic type/font scaling

---

## 📦 Future Enhancements

- [ ] Lottie animations for onboarding
- [ ] Micro-interactions on button presses
- [ ] Skeleton loaders with shimmer effects
- [ ] Confetti animations for goal completion
- [ ] Interactive chart animations
- [ ] Custom icon pack with SVG assets

---

**Version:** 1.0
**Last Updated:** 2025-11-11
**Design System Maintainer:** Eazy-Finance Team
