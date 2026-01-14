import 'package:meta/meta.dart';

@immutable
class BillCategory {
  const BillCategory({
    required this.id,
    required this.userId,
    required this.title,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
  });

  final String id;
  final String userId;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount;

  BillCategory copyWith({
    String? title,
    String? imageUrl,
    DateTime? updatedAt,
    int? usageCount,
  }) {
    return BillCategory(
      id: id,
      userId: userId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  factory BillCategory.fromMap(Map<String, dynamic> map) {
    return BillCategory(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      usageCount: map['usage_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'usage_count': usageCount,
    };
  }
}
