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
    return BillTransaction(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      categoryId: map['category_id'] as String? ?? '',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : DateTime.now(),
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
