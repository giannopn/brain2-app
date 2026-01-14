import 'package:flutter/material.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/screens/bill_details_page.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/models/bill_transaction.dart' as model;

class BillTransactionsPage extends StatefulWidget {
  const BillTransactionsPage({
    super.key,
    required this.categoryId,
    this.categoryTitle = 'ΔΕΗ',
    this.onBack,
    this.onAdd,
  });

  final String categoryId;
  final String categoryTitle;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;

  @override
  State<BillTransactionsPage> createState() => _BillTransactionsPageState();
}

class _BillTransactionsPageState extends State<BillTransactionsPage> {
  List<model.BillTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await BillTransactionsRepository.instance
          .fetchTransactionsByCategory(categoryId: widget.categoryId);

      // Sort by due date descending (most recent first)
      final sorted = List<model.BillTransaction>.from(transactions)
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

      if (mounted) {
        setState(() {
          _transactions = sorted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDeadline(DateTime dueDate, model.BillStatus status) {
    final today = DateTime.now();
    final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysDiff = dateOnly.difference(todayOnly).inDays;

    if (daysDiff == 0) {
      return 'Today';
    }
    if (daysDiff == 1) {
      return 'Tomorrow';
    }
    if (daysDiff > 1) {
      return 'in $daysDiff days';
    }

    // Past dates
    if (daysDiff == -1 && status != model.BillStatus.paid) {
      return 'yesterday';
    }
    if (daysDiff < 0 && status != model.BillStatus.paid) {
      return '${-daysDiff} days ago';
    }

    // Paid and past deadline -> full date
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';
  }

  BillStatusType _mapTransactionStatus(model.BillStatus status) {
    switch (status) {
      case model.BillStatus.paid:
        return BillStatusType.paid;
      case model.BillStatus.pending:
        return BillStatusType.pending;
      case model.BillStatus.overdue:
        return BillStatusType.overdue;
    }
  }

  double _totalAmount() {
    return _transactions.fold<double>(0, (sum, t) => sum + t.amount);
  }

  String _formatAmount(double amount) {
    final roundedUp = amount.ceil();
    return '$roundedUp€';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: widget.categoryTitle,
            onBack: widget.onBack ?? () => Navigator.pop(context),
            hideAddButton: true,
            paddingTop: 68,
            paddingBottom: 10,
            paddingHorizontal: 15,
            hasText: false,
            width: MediaQuery.of(context).size.width,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction History header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transaction History',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                _formatAmount(_totalAmount()),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Transaction items
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              for (
                                int i = 0;
                                i < _transactions.length;
                                i++
                              ) ...[
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BillDetailsPage(
                                          transactionId: _transactions[i].id,
                                        ),
                                      ),
                                    );

                                    // Reload transactions from cache when returning
                                    if (mounted) {
                                      await _loadTransactions();
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: BillsCard(
                                    type: BillsCardType.detailed,
                                    title: widget.categoryTitle,
                                    subtitle: _formatDeadline(
                                      _transactions[i].dueDate,
                                      _transactions[i].status,
                                    ),
                                    amount:
                                        _transactions[i].amount.toStringAsFixed(
                                          2,
                                        ) +
                                        '€',
                                    status: _mapTransactionStatus(
                                      _transactions[i].status,
                                    ),
                                    width: double.infinity,
                                  ),
                                ),
                                if (i < _transactions.length - 1)
                                  const SizedBox(height: 4),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
