import 'package:equatable/equatable.dart';

enum CategoryType { expense, income }

class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final CategoryType type;
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    required this.sortOrder,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, type, icon, sortOrder, createdAt];

  CategoryEntity copyWith({
    String? id,
    String? userId,
    String? name,
    CategoryType? type,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
