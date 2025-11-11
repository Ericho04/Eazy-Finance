// lib/models/goal.dart
// ✅ 基于实际Supabase数据库结构

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String deadline;
  final String category;
  final String priority;
  final bool isCompleted;
  final String? completedAt;
  final int pointsReward;
  final String createdAt;
  final String? updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.category,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    this.pointsReward = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount) * 100;
  }

  // Check if goal is overdue
  bool get isOverdue {
    if (isCompleted || deadline.isEmpty) return false;
    final deadlineDate = DateTime.parse(deadline);
    return DateTime.now().isAfter(deadlineDate);
  }

  // Days remaining
  int get daysRemaining {
    if (deadline.isEmpty) return -1;
    final deadlineDate = DateTime.parse(deadline);
    final difference = deadlineDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  // Remaining amount to reach target
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  // Copy with method for immutable updates
  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? deadline,
    String? category,
    String? priority,
    bool? isCompleted,
    String? completedAt,
    int? pointsReward,
    String? createdAt,
    String? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      pointsReward: pointsReward ?? this.pointsReward,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  // ✅ 正确的 fromJson - 使用 snake_case
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['user_id'] as String,              // snake_case
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),    // snake_case
      currentAmount: (json['current_amount'] as num).toDouble(),  // snake_case
      deadline: json['deadline'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      isCompleted: json['is_completed'] as bool,      // snake_case
      completedAt: json['completed_at'] as String?,   // snake_case
      pointsReward: json['points_reward'] as int? ?? 0, // snake_case
      createdAt: json['created_at'] as String,        // snake_case
      updatedAt: json['updated_at'] as String?,       // snake_case
    );
  }

  // ✅ 正确的 toJson - 返回 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,              // snake_case
      'title': title,
      'description': description,
      'target_amount': targetAmount,  // snake_case
      'current_amount': currentAmount, // snake_case
      'deadline': deadline,
      'category': category,
      'priority': priority,
      'is_completed': isCompleted,    // snake_case
      'completed_at': completedAt,    // snake_case
      'points_reward': pointsReward,  // snake_case
      'created_at': createdAt,        // snake_case
      'updated_at': updatedAt,        // snake_case
    };
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Goal categories
class GoalCategory {
  static const String savings = 'savings';
  static const String emergency = 'emergency';
  static const String travel = 'travel';
  static const String technology = 'technology';
  static const String education = 'education';
  static const String health = 'health';
  static const String home = 'home';
  static const String car = 'car';
  static const String investment = 'investment';

  static List<String> get allCategories => [
    savings,
    emergency,
    travel,
    technology,
    education,
    health,
    home,
    car,
    investment,
  ];

  static Map<String, String> get categoryEmojis => {
    savings: '💰',
    emergency: '🆘',
    travel: '✈️',
    technology: '💻',
    education: '📚',
    health: '🥗',
    home: '🏠',
    car: '🚗',
    investment: '📈',
  };

  static String getCategoryEmoji(String category) {
    return categoryEmojis[category] ?? '🎯';
  }
}

// Goal priorities
class GoalPriority {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';

  static List<String> get allPriorities => [low, medium, high];

  static Map<String, String> get priorityLabels => {
    low: 'Low Priority',
    medium: 'Medium Priority',
    high: 'High Priority',
  };

  static String getPriorityLabel(String priority) {
    return priorityLabels[priority] ?? 'Unknown Priority';
  }
}