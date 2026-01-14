import 'package:meta/meta.dart';

enum BillStatus {
  pending,
  paid,
  overdue;

  String toJson() => name;

  static BillStatus fromJson(String value) {
    return BillStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => BillStatus.pending,
    );
  }
}

@immutable
class BillTransaction {
  const BillTransaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillTransaction copyWith({
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
    String? receiptUrl,
    DateTime? updatedAt,
  }) {
    return BillTransaction(
      id: id,
      userId: userId,
      categoryId: categoryId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BillTransaction.fromMap(Map<String, dynamic> map) {
    // Parse due_date as a date-only string (e.g., "2026-01-15")
    // Create it as a local DateTime, not UTC
    DateTime parsedDueDate;
    if (map['due_date'] != null) {
      final dateStr = map['due_date'] as String;
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          parsedDueDate = DateTime(
            int.parse(parts[0]), // year
            int.parse(parts[1]), // month
            int.parse(parts[2]), // day
          );
        } else {
          parsedDueDate = DateTime.parse(dateStr);
        }
      } catch (_) {
        parsedDueDate = DateTime.now();
      }
    } else {
      parsedDueDate = DateTime.now();
    }

    return BillTransaction(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      categoryId: map['category_id'] as String? ?? '',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      dueDate: parsedDueDate,
      status: map['status'] != null
          ? BillStatus.fromJson(map['status'] as String)
          : BillStatus.pending,
      receiptUrl: map['receipt_url'] as String?,
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
      'category_id': categoryId,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0], // Date only
      'status': status.toJson(),
      'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
