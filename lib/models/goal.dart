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
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount) * 100;
  }

  // Calculate points reward (1 point per RM100 target)
  int get pointsReward {
    return (targetAmount / 100).floor();
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      deadline: json['deadline'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
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
    health: '🏥',
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