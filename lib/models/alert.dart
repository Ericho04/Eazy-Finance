// ✅ alert.dart - 基于 Supabase alerts 表

enum AlertType {
  budgetWarning,       // budget_warning in DB
  budgetExceeded,      // budget_exceeded in DB
  goalDeadline,        // goal_deadline in DB
  debtDue,             // debt_due in DB
  transactionAnomaly,  // transaction_anomaly in DB
  systemNotification,  // system_notification in DB
}

enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

class Alert {
  final String id;
  final String userId;
  final String title;
  final String message;
  final AlertType type;
  final AlertPriority priority;
  final bool isRead;
  final bool isActionable;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? readAt;

  Alert({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = AlertPriority.medium,
    this.isRead = false,
    this.isActionable = false,
    this.actionUrl,
    this.metadata,
    DateTime? createdAt,
    this.readAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if alert is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  // Check if alert is urgent (high or critical priority)
  bool get isUrgent {
    return priority == AlertPriority.high || priority == AlertPriority.critical;
  }

  // Copy with method
  Alert copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    AlertType? type,
    AlertPriority? priority,
    bool? isRead,
    bool? isActionable,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Alert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? (this.metadata != null ? Map.from(this.metadata!) : null),
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // Mark as read
  Alert markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  // ✅ toJson 使用 snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,  // ✅ snake_case
      'title': title,
      'message': message,
      'type': _alertTypeToString(type),
      'priority': priority.toString().split('.').last,
      'is_read': isRead,  // ✅ snake_case
      'is_actionable': isActionable,  // ✅ snake_case
      'action_url': actionUrl,  // ✅ snake_case
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),  // ✅ snake_case
      'read_at': readAt?.toIso8601String(),  // ✅ snake_case
    };
  }

  // ✅ fromJson 读取 snake_case
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // ✅ snake_case
      title: json['title'] as String,
      message: json['message'] as String,
      type: _stringToAlertType(json['type'] as String),
      priority: AlertPriority.values.firstWhere(
            (e) => e.toString().split('.').last == json['priority'],
        orElse: () => AlertPriority.medium,
      ),
      isRead: json['is_read'] as bool? ?? false,  // ✅ snake_case
      isActionable: json['is_actionable'] as bool? ?? false,  // ✅ snake_case
      actionUrl: json['action_url'] as String?,  // ✅ snake_case
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),  // ✅ snake_case
      readAt: json['read_at'] != null  // ✅ snake_case
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  // Helper: Convert AlertType to database string
  static String _alertTypeToString(AlertType type) {
    switch (type) {
      case AlertType.budgetWarning:
        return 'budget_warning';  // ✅ snake_case
      case AlertType.budgetExceeded:
        return 'budget_exceeded';  // ✅ snake_case
      case AlertType.goalDeadline:
        return 'goal_deadline';  // ✅ snake_case
      case AlertType.debtDue:
        return 'debt_due';  // ✅ snake_case
      case AlertType.transactionAnomaly:
        return 'transaction_anomaly';  // ✅ snake_case
      case AlertType.systemNotification:
        return 'system_notification';  // ✅ snake_case
    }
  }

  // Helper: Convert database string to AlertType
  static AlertType _stringToAlertType(String type) {
    switch (type) {
      case 'budget_warning':
        return AlertType.budgetWarning;
      case 'budget_exceeded':
        return AlertType.budgetExceeded;
      case 'goal_deadline':
        return AlertType.goalDeadline;
      case 'debt_due':
        return AlertType.debtDue;
      case 'transaction_anomaly':
        return AlertType.transactionAnomaly;
      case 'system_notification':
        return AlertType.systemNotification;
      default:
        return AlertType.systemNotification;
    }
  }

  @override
  String toString() {
    return 'Alert(id: $id, title: $title, type: $type, priority: $priority, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Alert utilities
class AlertUtils {
  static String getAlertTypeLabel(AlertType type) {
    switch (type) {
      case AlertType.budgetWarning:
        return 'Budget Warning';
      case AlertType.budgetExceeded:
        return 'Budget Exceeded';
      case AlertType.goalDeadline:
        return 'Goal Deadline';
      case AlertType.debtDue:
        return 'Debt Payment Due';
      case AlertType.transactionAnomaly:
        return 'Unusual Transaction';
      case AlertType.systemNotification:
        return 'System Notification';
    }
  }

  static String getAlertTypeEmoji(AlertType type) {
    switch (type) {
      case AlertType.budgetWarning:
        return '⚠️';
      case AlertType.budgetExceeded:
        return '🚨';
      case AlertType.goalDeadline:
        return '⏰';
      case AlertType.debtDue:
        return '💳';
      case AlertType.transactionAnomaly:
        return '🔍';
      case AlertType.systemNotification:
        return '📢';
    }
  }

  static String getPriorityLabel(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.low:
        return 'Low';
      case AlertPriority.medium:
        return 'Medium';
      case AlertPriority.high:
        return 'High';
      case AlertPriority.critical:
        return 'Critical';
    }
  }

  static String getPriorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.low:
        return '#4CAF50'; // Green
      case AlertPriority.medium:
        return '#FF9800'; // Orange
      case AlertPriority.high:
        return '#F44336'; // Red
      case AlertPriority.critical:
        return '#9C27B0'; // Purple
    }
  }

  // Get unread alerts count
  static int getUnreadCount(List<Alert> alerts) {
    return alerts.where((alert) => !alert.isRead).length;
  }

  // Get urgent alerts
  static List<Alert> getUrgentAlerts(List<Alert> alerts) {
    return alerts.where((alert) => alert.isUrgent && !alert.isRead).toList();
  }

  // Sort alerts by priority and date
  static List<Alert> sortAlerts(List<Alert> alerts) {
    final sorted = List<Alert>.from(alerts);
    sorted.sort((a, b) {
      // First by priority
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      // Then by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  // Create budget warning alert
  static Alert createBudgetWarningAlert({
    required String userId,
    required String budgetCategory,
    required double utilizationPercentage,
  }) {
    return Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Budget Warning: $budgetCategory',
      message: 'You\'ve used ${utilizationPercentage.toStringAsFixed(0)}% of your $budgetCategory budget.',
      type: AlertType.budgetWarning,
      priority: utilizationPercentage >= 90
          ? AlertPriority.high
          : AlertPriority.medium,
      isActionable: true,
      actionUrl: '/budgets',
      metadata: {
        'budget_category': budgetCategory,
        'utilization_percentage': utilizationPercentage,
      },
    );
  }

  // Create goal deadline alert
  static Alert createGoalDeadlineAlert({
    required String userId,
    required String goalTitle,
    required int daysRemaining,
  }) {
    return Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Goal Deadline Approaching',
      message: '$goalTitle has $daysRemaining days remaining.',
      type: AlertType.goalDeadline,
      priority: daysRemaining <= 7
          ? AlertPriority.high
          : AlertPriority.medium,
      isActionable: true,
      actionUrl: '/goals',
      metadata: {
        'goal_title': goalTitle,
        'days_remaining': daysRemaining,
      },
    );
  }
}