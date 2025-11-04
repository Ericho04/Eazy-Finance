# Easy Finance - Architecture Documentation

## Overview

Easy Finance follows **Clean Architecture** principles to ensure maintainability, testability, and scalability. The architecture separates concerns into distinct layers, each with specific responsibilities.

## Architecture Layers

### 1. Presentation Layer
**Location**: `lib/features/*/presentation/`

**Responsibilities**:
- Display UI to users
- Handle user interactions
- Manage local UI state with Riverpod
- Navigate between screens

**Components**:
- **Screens**: Full-page views (e.g., `DashboardScreen`, `TransactionsScreen`)
- **Widgets**: Reusable UI components (e.g., `TransactionCard`, `BudgetChart`)
- **Providers**: Riverpod providers for state management
- **View Models**: Business logic for UI (optional, can be merged with providers)

**Example**:
```dart
// Provider for transactions
final transactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repository = ref.read(transactionRepositoryProvider);
  final result = await repository.getTransactions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (transactions) => transactions,
  );
});

// Screen consuming the provider
class TransactionsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return transactionsAsync.when(
      data: (transactions) => TransactionList(transactions),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### 2. Domain Layer
**Location**: `lib/core/domain/` and `lib/features/*/domain/`

**Responsibilities**:
- Define business entities
- Declare repository interfaces
- Implement use cases (business logic)
- Define core types (Result, Failure)

**Components**:
- **Entities**: Pure Dart classes representing business models
- **Repositories**: Abstract interfaces for data access
- **Use Cases**: Single-responsibility business operations
- **Value Objects**: Immutable value types with validation

**Example**:
```dart
// Entity
class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final TransactionDirection direction;
  // ...
}

// Repository Interface
abstract class TransactionRepository {
  Future<Result<TransactionEntity>> createTransaction(TransactionEntity transaction);
  Future<Result<List<TransactionEntity>>> getTransactions();
}

// Use Case
class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Result<TransactionEntity>> call(TransactionEntity transaction) async {
    // Business logic validation
    if (transaction.amount <= 0) {
      return Left(ValidationFailure('Amount must be positive'));
    }

    return await repository.createTransaction(transaction);
  }
}
```

### 3. Data Layer
**Location**: `lib/core/data/` and `lib/features/*/data/`

**Responsibilities**:
- Implement repository interfaces
- Map between DTOs and Entities
- Handle data sources (Supabase, SQLite)
- Manage offline caching and sync

**Components**:
- **Repository Implementations**: Concrete classes implementing domain repositories
- **DTOs (Data Transfer Objects)**: JSON-serializable models for API/database
- **Data Sources**: Abstractions for Supabase and SQLite
- **Mappers**: Convert between DTOs and Entities

**Example**:
```dart
// DTO
@JsonSerializable()
class TransactionDto {
  final String id;
  final String userId;
  final double amount;
  final String direction;

  // JSON serialization methods
  factory TransactionDto.fromJson(Map<String, dynamic> json) => _$TransactionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);

  // Mapper to Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      amount: amount,
      direction: direction == 'inflow' ? TransactionDirection.inflow : TransactionDirection.outflow,
    );
  }
}

// Repository Implementation
class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseClient supabase;
  final LocalDatabase localDb;

  @override
  Future<Result<TransactionEntity>> createTransaction(TransactionEntity transaction) async {
    try {
      // Convert entity to DTO
      final dto = TransactionDto.fromEntity(transaction);

      // Save to Supabase
      final response = await supabase
        .from('txn')
        .insert(dto.toJson())
        .select()
        .single();

      // Save to local cache
      await localDb.saveTransaction(dto);

      // Convert response to entity
      final savedDto = TransactionDto.fromJson(response);
      return Right(savedDto.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

## Data Flow

### Read Operation (Query)
```
User Interaction
    ↓
Presentation Layer (Widget)
    ↓
Riverpod Provider
    ↓
Use Case (optional)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Supabase/SQLite)
    ↓
DTO → Entity Mapping
    ↓
Result<Entity> returned
    ↓
Provider updates UI
    ↓
Widget rebuilds
```

### Write Operation (Command)
```
User Interaction
    ↓
Presentation Layer (Form Submit)
    ↓
Riverpod Provider/Notifier
    ↓
Use Case Validation
    ↓
Repository Interface
    ↓
Repository Implementation
    ↓
Entity → DTO Mapping
    ↓
Save to Remote (Supabase)
    ↓
Save to Local Cache (SQLite)
    ↓
DTO → Entity Mapping
    ↓
Result<Entity> returned
    ↓
Provider notifies listeners
    ↓
UI updates
```

## Key Design Patterns

### 1. Repository Pattern
Abstracts data access logic, allowing easy swapping of data sources.

### 2. Result Pattern (Either)
```dart
typedef Result<T> = Either<Failure, T>;

// Usage
final result = await repository.getTransaction(id);
result.fold(
  (failure) => showError(failure.message),
  (transaction) => displayTransaction(transaction),
);
```

### 3. Dependency Injection (Riverpod)
```dart
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final localDb = ref.read(localDatabaseProvider);
  return TransactionRepositoryImpl(supabase, localDb);
});
```

### 4. DTO Mapping
Separates API/DB models from business entities to prevent coupling.

## Offline-First Strategy

### Sync Queue
```dart
class SyncQueue {
  final LocalDatabase db;

  Future<void> enqueuePendingOperation(Operation op) async {
    await db.savePendingOperation(op);
  }

  Future<void> processPendingOperations() async {
    final pending = await db.getPendingOperations();

    for (final op in pending) {
      try {
        await syncToRemote(op);
        await db.markOperationSynced(op.id);
      } catch (e) {
        // Retry later
      }
    }
  }
}
```

### Conflict Resolution
- **Last Write Wins**: For simple cases
- **Timestamp-based**: Use `updated_at` to determine latest version
- **Manual Resolution**: For critical data, prompt user

## State Management with Riverpod

### Provider Types

**1. Provider**: Immutable, cacheable values
```dart
final configProvider = Provider<AppConfig>((ref) => AppConfig());
```

**2. FutureProvider**: Async data fetching
```dart
final transactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getTransactions().then((result) => result.getOrElse(() => []));
});
```

**3. StateNotifierProvider**: Mutable state
```dart
class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository repository;

  BudgetNotifier(this.repository) : super(BudgetState.initial());

  Future<void> loadBudget(int year, int month) async {
    state = state.copyWith(loading: true);
    final result = await repository.getBudget(year, month);
    state = result.fold(
      (failure) => state.copyWith(loading: false, error: failure.message),
      (budget) => state.copyWith(loading: false, budget: budget),
    );
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(ref.read(budgetRepositoryProvider));
});
```

## Error Handling

### Failure Hierarchy
```
Failure (abstract)
├── ServerFailure (network, API errors)
├── CacheFailure (local DB errors)
├── AuthFailure (authentication errors)
├── ValidationFailure (business rule violations)
├── NotFoundFailure (resource not found)
├── PermissionFailure (RLS violations)
└── UnknownFailure (unexpected errors)
```

### Error Propagation
```dart
// Repository returns Result
Future<Result<Transaction>> getTransaction(String id) async {
  try {
    final data = await supabase.from('txn').select().eq('id', id).single();
    return Right(TransactionDto.fromJson(data).toEntity());
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      return Left(NotFoundFailure('Transaction not found'));
    }
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}

// UI handles errors gracefully
final result = await repository.getTransaction(id);
result.fold(
  (failure) {
    if (failure is NotFoundFailure) {
      showSnackbar('Transaction not found');
    } else if (failure is ServerFailure) {
      showSnackbar('Network error. Please try again.');
    } else {
      showSnackbar('An error occurred');
    }
  },
  (transaction) => displayTransaction(transaction),
);
```

## Testing Strategy

### Unit Tests
Test business logic in isolation.

```dart
void main() {
  late MockTransactionRepository mockRepository;
  late CreateTransactionUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = CreateTransactionUseCase(mockRepository);
  });

  test('should create transaction when amount is positive', () async {
    // Arrange
    final transaction = TransactionEntity(amount: 100, ...);
    when(mockRepository.createTransaction(transaction))
      .thenAnswer((_) async => Right(transaction));

    // Act
    final result = await useCase(transaction);

    // Assert
    expect(result.isRight(), true);
    verify(mockRepository.createTransaction(transaction));
  });

  test('should return ValidationFailure when amount is zero', () async {
    // Arrange
    final transaction = TransactionEntity(amount: 0, ...);

    // Act
    final result = await useCase(transaction);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should return failure'),
    );
  });
}
```

### Widget Tests
Test UI components.

```dart
void main() {
  testWidgets('TransactionCard displays amount correctly', (tester) async {
    final transaction = TransactionEntity(
      amount: 100.50,
      direction: TransactionDirection.outflow,
      ...
    );

    await tester.pumpWidget(
      MaterialApp(home: TransactionCard(transaction)),
    );

    expect(find.text('RM 100.50'), findsOneWidget);
  });
}
```

### Integration Tests
Test complete user flows.

```dart
void main() {
  testWidgets('User can create a transaction', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));

    // Navigate to add transaction
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byKey(Key('amount')), '100');
    await tester.tap(find.text('Food'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify transaction appears in list
    expect(find.text('RM 100.00'), findsOneWidget);
  });
}
```

## Performance Optimizations

### 1. Lazy Loading
```dart
final transactionsProvider = FutureProvider.autoDispose.family<
  List<TransactionEntity>,
  TransactionFilter
>((ref, filter) async {
  // Provider is disposed when no longer watched
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getTransactions(filter: filter);
});
```

### 2. Pagination
```dart
class TransactionsPaginator extends StateNotifier<PaginatedState> {
  int _page = 0;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore || state.loading) return;

    state = state.copyWith(loading: true);
    final newItems = await repository.getTransactions(
      page: _page,
      pageSize: 20,
    );

    _hasMore = newItems.length == 20;
    _page++;

    state = state.copyWith(
      items: [...state.items, ...newItems],
      loading: false,
    );
  }
}
```

### 3. Memoization
```dart
final monthlyTotalsProvider = Provider.family<double, DateTime>((ref, month) {
  final transactions = ref.watch(transactionsProvider);

  return transactions.when(
    data: (list) => list
      .where((t) => isSameMonth(t.occurredOn, month))
      .fold(0.0, (sum, t) => sum + t.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
```

### 4. Database Indexes
Ensure proper indexes on frequently queried fields:
- `txn(user_id, occurred_on DESC)`
- `budget(user_id, year, month)`
- `goal(user_id, status)`

## Security Considerations

### 1. Row-Level Security (RLS)
All Supabase tables have RLS policies ensuring users can only access their own data.

### 2. Input Validation
Validate all user inputs in the domain layer before persisting.

### 3. Sensitive Data
- Never log sensitive information
- Use secure storage for local cache encryption
- Clear cache on logout

### 4. API Keys
- Store Supabase keys in environment variables
- Use different keys for dev/staging/prod
- Never commit keys to version control

## Scalability Considerations

### 1. Modular Features
Each feature is self-contained, allowing for:
- Parallel development
- Feature flags
- Gradual rollout

### 2. Edge Functions
Offload complex computations to Supabase Edge Functions:
- Tax calculations
- Financial insights generation
- Report generation

### 3. Caching Strategy
- Cache static data (tax categories) indefinitely
- Cache user data with TTL
- Invalidate cache on mutations

## Future Enhancements

1. **Multi-currency Support**: Extend to support currencies beyond MYR
2. **Collaborative Budgets**: Share budgets with family members
3. **AI Insights**: Machine learning for spending predictions
4. **Investment Tracking**: Stocks, crypto, mutual funds
5. **Open Banking Integration**: Auto-sync with Malaysian banks
6. **Bill Reminders**: Recurring payment reminders
7. **Receipt Scanning**: OCR for expense tracking

---

This architecture provides a solid foundation for building a maintainable, testable, and scalable personal finance application.
