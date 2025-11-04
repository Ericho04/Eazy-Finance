# Easy Finance 💰

**Production-Ready Personal Finance App for Malaysia**

A mobile-first, offline-capable personal finance application built with Flutter and Supabase, designed specifically for Malaysian users with features like budgeting, goal tracking, debt management, tax planning, and a gamified lucky draw system.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Database Schema](#database-schema)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)

## ✨ Features

### 1. Financial Insights & Goals
- **Transaction Management**: Track income and expenses with categories
- **Monthly Insights**: Visualize spending with bar/pie charts
- **Month-over-Month Comparisons**: Analyze spending trends
- **Income-Based Suggestions**: Get smart spending recommendations
- **Budget Alerts**: Notifications when approaching category limits
- **Goal Tracking**: Set financial goals with progress monitoring
- **Goal Contributions**: Log contributions towards your goals
- **Lucky Draw System**: Earn entries by completing goals and win rewards

### 2. Smart Budgeting & Planning
- **Monthly Budgets**: Create budgets based on your income
- **Dynamic Budget Caps**: Automatic adjustment of category limits based on spending patterns
- **Overspending Alerts**: Real-time notifications with visual flags (green/amber/red)
- **Budget Simulation**: Preview different budget scenarios and their impact
- **Historical Tracking**: View budget performance over time

### 3. Debt Management
- **Multiple Debt Tracking**: Manage credit cards, loans, and other debts
- **Amortization Calculator**: See detailed payment breakdowns
- **Payoff Forecasting**: Estimate when you'll be debt-free
- **DTI Analysis**: Debt-to-Income ratio calculation with affordability labels (Safe/Borderline/Risky)
- **Payment Reminders**: Notifications before due dates
- **Extra Payment Tracking**: Calculate impact of additional payments

### 4. Tax Planning (Malaysian Tax System)
- **Tax Relief Tracking**: Track deductible expenses across 20+ categories
- **Relief Quota Monitoring**: See remaining limits for each category
- **Tax Savings Calculator**: Estimate annual tax savings
- **PDF Export**: Generate tax summary reports
- **Categories Include**:
  - EPF/KWSP contributions
  - Life insurance
  - Education (SSPN)
  - Medical expenses
  - Books and education
  - Sports equipment
  - Technology purchases
  - And more...

### 5. Settings & Preferences
- **Profile Management**: Update personal information
- **Theme Toggle**: Light and dark mode support
- **Notification Preferences**: Customize alerts
- **Currency**: MYR with Malaysian locale formatting
- **Privacy & Help**: Access support and privacy information

## 🛠 Tech Stack

### Frontend
- **Flutter/Dart**: Cross-platform mobile framework
- **Riverpod**: State management
- **go_router**: Declarative routing
- **fl_chart**: Data visualization
- **intl**: Internationalization and formatting
- **drift**: Local SQLite database for offline support
- **flutter_local_notifications**: Push notifications

### Backend
- **Supabase**: Backend-as-a-Service
  - PostgreSQL database
  - Authentication
  - Row-Level Security (RLS)
  - Edge Functions
- **TypeScript**: Edge Functions for server-side logic

### Architecture
- **Clean Architecture**: Separation of concerns with distinct layers
- **Offline-First**: Local SQLite cache with queue-based sync
- **Strong Typing**: Type-safe entities and DTOs
- **Result Pattern**: Elegant error handling with Either<Failure, Success>

## 🏗 Architecture

The app follows **Clean Architecture** principles with three main layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer               │
│  (UI, Widgets, Riverpod Providers)      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                    │
│  (Entities, Use Cases, Repositories)     │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                     │
│  (Repositories, DTOs, Data Sources)      │
└─────────────────────────────────────────┘
         ↓                    ↓
┌──────────────────┐  ┌──────────────────┐
│    Supabase      │  │  SQLite (Drift)  │
│   (Remote DB)    │  │   (Local Cache)  │
└──────────────────┘  └──────────────────┘
```

### Layer Responsibilities

**Presentation Layer**
- UI components and screens
- Riverpod providers for state management
- User input handling
- Navigation

**Domain Layer**
- Business entities (User, Transaction, Budget, Goal, Debt, Tax)
- Use cases (business logic)
- Repository interfaces
- Core types (Result, Failure)

**Data Layer**
- Repository implementations
- Data Transfer Objects (DTOs)
- Data source abstractions
- Mappers (DTO ↔ Entity)
- API clients (Supabase, SQLite)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (≥3.13.0)
- Dart SDK (≥3.1.0)
- Supabase account
- Android Studio / Xcode (for mobile development)

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Eazy-Finance.git
cd Eazy-Finance
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Run the migration to create the database schema:

```bash
# In the Supabase dashboard, go to SQL Editor and run:
# supabase/migrations/20250104000001_easy_finance_schema.sql
```

3. Update `lib/core/config/env_config.dart` with your Supabase credentials:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

**Alternative**: Use environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 4. Deploy Edge Functions (Optional)

Deploy the tax tips Edge Function:

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Deploy function
supabase functions deploy tax-tips
```

### 5. Run the App

```bash
# For development
flutter run

# For Android release
flutter build apk --release

# For iOS release
flutter build ios --release
```

## 🗄 Database Schema

### Core Tables

**app_user**: User profiles
- `id` (UUID, PK)
- `email` (TEXT)
- `full_name` (TEXT)
- `created_at` (TIMESTAMPTZ)

**category**: Transaction categories
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `name` (TEXT)
- `type` (expense/income)
- `icon` (TEXT)
- `sort_order` (INT)

**txn**: Transactions
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `category_id` (UUID, FK)
- `amount` (NUMERIC)
- `direction` (inflow/outflow)
- `occurred_on` (DATE)
- `note` (TEXT)

**budget**: Monthly budgets
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `year` (INT)
- `month` (INT)
- `monthly_income` (NUMERIC)

**budget_cap**: Category spending limits
- `id` (UUID, PK)
- `budget_id` (UUID, FK)
- `category_id` (UUID, FK)
- `planned_amount` (NUMERIC)
- `dynamic_amount` (NUMERIC)

**goal**: Financial goals
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `title` (TEXT)
- `target_amount` (NUMERIC)
- `deadline` (DATE)
- `status` (active/completed/archived)

**goal_contribution**: Goal contributions
- `id` (UUID, PK)
- `goal_id` (UUID, FK)
- `amount` (NUMERIC)
- `contributed_on` (DATE)
- `note` (TEXT)

**debt**: Debt tracking
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `name` (TEXT)
- `principal` (NUMERIC)
- `apr` (NUMERIC)
- `term_months` (INT)
- `due_day` (INT)
- `start_date` (DATE)
- `extra_monthly_payment` (NUMERIC)

**tax_profile**: Tax profiles
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `assessment_year` (INT)

**tax_relief_category**: Malaysian tax relief categories
- `id` (UUID, PK)
- `code` (TEXT)
- `label` (TEXT)
- `annual_limit` (NUMERIC)

**tax_claim**: Tax claims
- `id` (UUID, PK)
- `tax_profile_id` (UUID, FK)
- `category_id` (UUID, FK)
- `amount` (NUMERIC)
- `claimed_on` (DATE)

### Security

All tables have **Row-Level Security (RLS)** enabled, ensuring users can only access their own data. Policies are defined in the migration file.

### Indexes

Performance indexes are created on:
- `txn(user_id, occurred_on)`
- `budget(user_id, year, month)`
- `goal(user_id)`
- `debt(user_id)`
- And more...

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── env_config.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user_entity.dart
│   │   │   ├── transaction_entity.dart
│   │   │   ├── budget_entity.dart
│   │   │   ├── goal_entity.dart
│   │   │   ├── debt_entity.dart
│   │   │   ├── tax_entity.dart
│   │   │   └── lucky_draw_entity.dart
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── transaction_repository.dart
│   │       ├── budget_repository.dart
│   │       ├── goal_repository.dart
│   │       └── debt_repository.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── result.dart
│   ├── network/
│   │   └── supabase_client.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── transactions/
│   ├── budget/
│   ├── goals/
│   ├── debt/
│   ├── tax/
│   └── settings/
└── main.dart

supabase/
├── migrations/
│   └── 20250104000001_easy_finance_schema.sql
└── functions/
    └── tax-tips/
        └── index.ts
```

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Run Widget Tests

```bash
flutter test test/widget_test.dart
```

### Run Integration Tests

```bash
flutter test integration_test/
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Key Test Areas

- **Business Logic**: Amortization calculations, DTI analysis, budget cap adjustments
- **Use Cases**: Transaction creation, goal completion, tax calculations
- **Widgets**: Screen rendering, user interactions
- **Integration**: End-to-end flows (auth, transaction creation, goal completion)

## 📦 Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Sign and deploy to Play Store
```

### iOS

```bash
# Build iOS
flutter build ios --release

# Archive and deploy to App Store
```

### Environment Configuration

For production builds, use environment variables:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-prod-url.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-prod-anon-key
```

## 🔐 Security & Privacy (PDPA Compliance)

This app is designed with Malaysian Personal Data Protection Act (PDPA) compliance in mind:

1. **Minimal Data Collection**: Only essential data is stored
2. **User Consent**: Clear terms and privacy policy
3. **Data Encryption**: All data encrypted in transit (HTTPS/TLS)
4. **Row-Level Security**: Supabase RLS ensures data isolation
5. **Right to Deletion**: Users can delete their accounts and all associated data
6. **Data Portability**: Export features for user data
7. **Local Storage**: Sensitive data encrypted on device

## 📱 Supported Platforms

- ✅ Android (Primary target)
- ✅ iOS (Ready)
- ⚠️ Web (Partially supported)
- ⚠️ Desktop (Not optimized)

## 🎯 Performance Targets

- Dashboard initial load: ≤ 2s on 4G
- Transaction list rendering: ≤ 500ms for 100 items
- Offline operation: Full CRUD support
- Sync latency: ≤ 1s on good connection

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Standards

- Follow Dart/Flutter style guide
- Use meaningful variable names
- Write comments for complex logic
- Add tests for new features
- Update documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Development Team** - Initial work

## 🙏 Acknowledgments

- Flutter and Dart teams
- Supabase team
- Malaysian tax system documentation
- Open source community

## 📞 Support

For support, please:
1. Check the [Documentation](docs/)
2. Search existing [Issues](https://github.com/yourusername/Eazy-Finance/issues)
3. Create a new issue if needed

---

**Built with ❤️ for Malaysian users**

*Easy Finance - Making personal finance management easy and accessible*
