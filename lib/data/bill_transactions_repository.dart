import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brain2/models/bill_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:brain2/services/notification_service.dart';
import 'package:brain2/data/bill_categories_repository.dart';

class BillTransactionsRepository {
  BillTransactionsRepository._internal() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        // On sign out, clear local cache and cancel all scheduled notifications
        clearCache();
        NotificationService.instance.cancelAll();
      }
    });
  }

  static final BillTransactionsRepository instance =
      BillTransactionsRepository._internal();

  List<BillTransaction>? _cachedTransactions;
  NotificationScheduleInfo? lastNotificationInfo;

  List<BillTransaction>? get cachedTransactions => _cachedTransactions;

  void setCache(List<BillTransaction> transactions) {
    _cachedTransactions = transactions;
  }

  /// Fetch all transactions for the current user
  Future<List<BillTransaction>> fetchBillTransactions({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedTransactions != null) {
      return _cachedTransactions!;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      clearCache();
      return [];
    }

    final response = await Supabase.instance.client
        .from('bill_transactions')
        .select()
        .eq('user_id', user.id)
        .order('due_date', ascending: false);

    final transactions = (response as List<dynamic>)
        .map((item) => BillTransaction.fromMap(item as Map<String, dynamic>))
        .toList();

    _cachedTransactions = transactions;
    return transactions;
  }

  /// Fetch transactions for a specific category
  Future<List<BillTransaction>> fetchTransactionsByCategory({
    required String categoryId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedTransactions != null) {
      return _cachedTransactions!
          .where((t) => t.categoryId == categoryId)
          .toList();
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return [];
    }

    final response = await Supabase.instance.client
        .from('bill_transactions')
        .select()
        .eq('user_id', user.id)
        .eq('category_id', categoryId)
        .order('due_date', ascending: false);

    final transactions = (response as List<dynamic>)
        .map((item) => BillTransaction.fromMap(item as Map<String, dynamic>))
        .toList();

    return transactions;
  }

  /// Create a new bill transaction
  Future<BillTransaction> createBillTransaction({
    required String categoryId,
    required double amount,
    required DateTime dueDate,
    BillStatus status = BillStatus.pending,
    String? receiptUrl,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create a transaction');
    }

    final response = await Supabase.instance.client
        .from('bill_transactions')
        .insert({
          'user_id': user.id,
          'category_id': categoryId,
          'amount': amount,
          'due_date': dueDate.toIso8601String().split('T')[0],
          'status': status.toJson(),
          if (receiptUrl != null) 'receipt_url': receiptUrl,
        })
        .select()
        .single();

    final newTransaction = BillTransaction.fromMap(response);

    // Add to cache
    if (_cachedTransactions != null) {
      _cachedTransactions = [newTransaction, ..._cachedTransactions!];
    }

    // Schedule local notification if pending or overdue and due date is today or future
    try {
      if (newTransaction.status == BillStatus.pending ||
          newTransaction.status == BillStatus.overdue) {
        final info = await NotificationService.instance.scheduleDueNotification(
          transactionId: newTransaction.id,
          title: _buildNotificationTitle(newTransaction),
          body: _buildNotificationBody(newTransaction),
          dueDate: newTransaction.dueDate,
        );
        if (info != null) {
          lastNotificationInfo = info;
        }
      }
    } catch (e, st) {
      debugPrint('createBillTransaction: notification schedule failed: $e');
      debugPrint('$st');
    }

    return newTransaction;
  }

  /// Update an existing bill transaction
  Future<BillTransaction> updateBillTransaction({
    required String id,
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
    String? receiptUrl,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to update a transaction');
    }

    final updateData = <String, dynamic>{};
    if (amount != null) updateData['amount'] = amount;
    if (dueDate != null) {
      updateData['due_date'] = dueDate.toIso8601String().split('T')[0];
    }
    if (status != null) updateData['status'] = status.toJson();
    if (receiptUrl != null) updateData['receipt_url'] = receiptUrl;

    if (updateData.isEmpty) {
      throw Exception('No fields to update');
    }

    final response = await Supabase.instance.client
        .from('bill_transactions')
        .update(updateData)
        .eq('id', id)
        .eq('user_id', user.id)
        .select()
        .single();

    final updatedTransaction = BillTransaction.fromMap(response);

    // Update cache
    if (_cachedTransactions != null) {
      _cachedTransactions = _cachedTransactions!.map((t) {
        return t.id == id ? updatedTransaction : t;
      }).toList();
    }

    // Update notifications according to changes
    try {
      if (status != null) {
        if (status == BillStatus.paid) {
          await NotificationService.instance.cancelForTransaction(
            updatedTransaction.id,
          );
        } else if (status == BillStatus.pending ||
            status == BillStatus.overdue) {
          final info = await NotificationService.instance
              .rescheduleForTransaction(
                transactionId: updatedTransaction.id,
                title: _buildNotificationTitle(updatedTransaction),
                body: _buildNotificationBody(updatedTransaction),
                dueDate: updatedTransaction.dueDate,
              );
          if (info != null) {
            lastNotificationInfo = info;
          }
        }
      } else if (dueDate != null) {
        // Due date changed only
        final info = await NotificationService.instance
            .rescheduleForTransaction(
              transactionId: updatedTransaction.id,
              title: _buildNotificationTitle(updatedTransaction),
              body: _buildNotificationBody(updatedTransaction),
              dueDate: updatedTransaction.dueDate,
            );
        if (info != null) {
          lastNotificationInfo = info;
        }
      }
    } catch (e, st) {
      debugPrint('updateBillTransaction: notification update failed: $e');
      debugPrint('$st');
    }

    return updatedTransaction;
  }

  /// Mark a transaction as paid
  Future<BillTransaction> markAsPaid(String id) async {
    return updateBillTransaction(id: id, status: BillStatus.paid);
  }

  /// Mark a transaction as overdue
  Future<BillTransaction> markAsOverdue(String id) async {
    return updateBillTransaction(id: id, status: BillStatus.overdue);
  }

  /// Delete a bill transaction
  Future<void> deleteBillTransaction(String id) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to delete a transaction');
    }

    await Supabase.instance.client
        .from('bill_transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);

    // Remove from cache
    if (_cachedTransactions != null) {
      _cachedTransactions = _cachedTransactions!
          .where((t) => t.id != id)
          .toList();
    }

    // Cancel scheduled notification for this transaction
    try {
      await NotificationService.instance.cancelForTransaction(id);
    } catch (e, st) {
      debugPrint('deleteBillTransaction: notification cancel failed: $e');
      debugPrint('$st');
    }
  }

  void clearCache() {
    _cachedTransactions = null;
  }

  /// Optional: Re-create notifications for all cached pending transactions.
  /// Useful after app start when you fetch and cache transactions.
  Future<void> syncNotificationsFromCached() async {
    final list = _cachedTransactions;
    if (list == null || list.isEmpty) return;
    for (final t in list) {
      if (t.status == BillStatus.pending || t.status == BillStatus.overdue) {
        try {
          await NotificationService.instance.scheduleDueNotification(
            transactionId: t.id,
            title: _buildNotificationTitle(t),
            body: _buildNotificationBody(t),
            dueDate: t.dueDate,
          );
        } catch (e, st) {
          debugPrint('syncNotificationsFromCached: schedule failed: $e');
          debugPrint('$st');
        }
      }
    }
  }

  String _buildNotificationTitle(BillTransaction t) {
    final categoryTitle = _lookupCategoryTitle(t.categoryId);
    return '${categoryTitle ?? 'Bill'} due today';
  }

  String _buildNotificationBody(BillTransaction t) {
    final formattedAmount = t.amount.toStringAsFixed(2);
    return 'Amount: $formattedAmount€';
  }

  String? _lookupCategoryTitle(String categoryId) {
    final cached = BillCategoriesRepository.instance.cachedCategories;
    if (cached == null || cached.isEmpty) return null;
    for (final category in cached) {
      if (category.id == categoryId && category.title.isNotEmpty) {
        return category.title;
      }
    }
    return null;
  }
}
