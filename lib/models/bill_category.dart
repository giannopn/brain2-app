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
  });

  final String id;
  final String userId;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillCategory copyWith({
    String? title,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return BillCategory(
      id: id,
      userId: userId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    };
  }
}
