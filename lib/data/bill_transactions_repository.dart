import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brain2/models/bill_transaction.dart';

class BillTransactionsRepository {
  BillTransactionsRepository._internal() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        clearCache();
      }
    });
  }

  static final BillTransactionsRepository instance =
      BillTransactionsRepository._internal();

  List<BillTransaction>? _cachedTransactions;

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
  }

  void clearCache() {
    _cachedTransactions = null;
  }
}
